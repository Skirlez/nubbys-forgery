using UndertaleModLib.Models;
using UndertaleModLib.Util;
using UndertaleModLib.Decompiler;

// A script to merge Nubby's Number Factory and the modloader, Nubby's Forgery.
// Scripts used for reference from UndertaleModTool:
// ImportGraphics.csx
// GameObjectCopyInternal.csx

EnsureDataLoaded();

string runningDirectory = Path.GetDirectoryName(ScriptPath);

string modloaderPatchesPath = Path.GetFullPath(Path.Combine(runningDirectory, "..", "patches"));
string modloaderDataPath = Path.GetFullPath(Path.Combine(runningDirectory, "data.win"));

int stringListLength = Data.Strings.Count;

UndertaleData modloaderData = UndertaleIO.Read(new FileStream(modloaderDataPath, FileMode.Open, FileAccess.Read));

uint addInstanceId = Data.GeneralInfo.LastObj - 100000;
Data.GeneralInfo.LastObj += modloaderData.GeneralInfo.LastObj - 100000;

int lastTexturePage = Data.EmbeddedTextures.Count - 1;
int lastTexturePageItem = Data.TexturePageItems.Count - 1;

Dictionary<UndertaleEmbeddedTexture, int> dict = new Dictionary<UndertaleEmbeddedTexture, int>();
foreach (UndertaleEmbeddedTexture embeddedTexture in modloaderData.EmbeddedTextures) {
	if (embeddedTexture.TextureInfo.Name.Content == "__YY__0fallbacktexture.png_YYG_AUTO_GEN_TEX_GROUP_NAME_")
		continue;

	UndertaleEmbeddedTexture newTexture = new UndertaleEmbeddedTexture();
	lastTexturePage++;
	newTexture.Name = new UndertaleString("Texture " + lastTexturePage);
	newTexture.TextureData.Image = embeddedTexture.TextureData.Image;
	Data.EmbeddedTextures.Add(newTexture);

	dict.Add(embeddedTexture, lastTexturePage);
}

foreach (UndertaleSprite sprite in modloaderData.Sprites) {
	Data.Sprites.Add(sprite);
	foreach (UndertaleSprite.TextureEntry textureEntry in sprite.Textures) {
		int newIndex = dict[textureEntry.Texture.TexturePage];
		textureEntry.Texture.TexturePage = Data.EmbeddedTextures[newIndex];
		lastTexturePageItem++;
		textureEntry.Texture.Name = new UndertaleString("PageItem " + lastTexturePageItem);
		Data.TexturePageItems.Add(textureEntry.Texture);
	}
}

foreach (UndertaleSound sound in modloaderData.Sounds) {
	sound.AudioGroup = Data.AudioGroups[0];
	Data.Sounds.Add(sound);
	Data.EmbeddedAudio.Add(sound.AudioFile);
}

foreach (UndertaleCode code in modloaderData.Code)
	Data.Code.Add(code);

foreach (UndertaleFunction function in modloaderData.Functions) {
	Data.Functions.Add(function);
	function.NameStringID += stringListLength;
}

foreach (UndertaleVariable variable in modloaderData.Variables) {
	Data.Variables.Add(variable);

	if (variable.VarID == variable.NameStringID && variable.VarID != 0)
		variable.VarID += stringListLength;
	
	variable.NameStringID += stringListLength;
	
}
Data.InstanceVarCount += modloaderData.InstanceVarCount;
Data.InstanceVarCountAgain += modloaderData.InstanceVarCountAgain;
Data.MaxLocalVarCount = Math.Max(Data.MaxLocalVarCount, modloaderData.MaxLocalVarCount);

foreach (UndertaleCodeLocals locals in modloaderData.CodeLocals) 
	Data.CodeLocals.Add(locals);
foreach (UndertaleScript script in modloaderData.Scripts) 
	Data.Scripts.Add(script);


foreach (UndertaleGameObject gameObject in modloaderData.GameObjects) {
	UndertaleGameObject parent = gameObject.ParentId;
	if (parent != null) {
		UndertaleGameObject parentFromNNF = Data.GameObjects.ByName(parent.Name.Content);
		if (parentFromNNF != null) {
			gameObject.ParentId = parentFromNNF;
		}
	}
	Data.GameObjects.Add(gameObject);
}

foreach (UndertaleRoom room in modloaderData.Rooms) {
	Data.Rooms.Add(room);
	foreach (UndertaleRoom.Layer layer in room.Layers) {
		if (layer.LayerType == UndertaleRoom.LayerType.Instances) {
			foreach (UndertaleRoom.GameObject gameObject in layer.InstancesData.Instances)
				gameObject.InstanceID += addInstanceId;
		}
	}
}



foreach (UndertaleAnimationCurve curve in modloaderData.AnimationCurves)
	Data.AnimationCurves.Add(curve);


foreach (UndertaleResourceById<UndertaleRoom, UndertaleChunkROOM> room in modloaderData.GeneralInfo.RoomOrder)
	Data.GeneralInfo.RoomOrder.Add(room);

Data.GeneralInfo.FunctionClassifications |= modloaderData.GeneralInfo.FunctionClassifications;

foreach (UndertaleGlobalInit script in modloaderData.GlobalInitScripts)
	Data.GlobalInitScripts.Add(script);

foreach (UndertaleString str in modloaderData.Strings)
	Data.Strings.Add(str);

Data.GeneralInfo.Info |= UndertaleGeneralInfo.InfoFlags.ShowCursor;
Data.Options.Info |= UndertaleOptions.OptionsFlags.ShowCursor;

// Apply the patches

string[] files = Directory.GetFiles(modloaderPatchesPath);

foreach (string file in files) {
	if (Path.GetExtension(file) == ".gml") {
		string codeEntryName = Path.GetFileNameWithoutExtension(file);
		string patches = File.ReadAllText(file);
		applyPatches(codeEntryName, patches);
	}
}

void applyPatches(string codeEntryName, string patches) {
	UndertaleCode entry = Data.Code.ByName(codeEntryName);
	string targetPattern = @"// TARGET: ([^\n\r]+)";
	string[] sections = Regex.Split(patches, targetPattern);

	for (int i = 1; i < sections.Length; i += 2) {
		string code = GetDecompiledText(entry);
		string target = sections[i];
		string patch = sections[i + 1].Trim();
		string finalResult;
		switch (target) {
			case "TAIL":
				finalResult = code + "\n" + patch;
				break;
			case "HEAD": 
				finalResult = patch + "\n" + code;
				break;
			case "REPLACE":
				finalResult = patch;
				break;
			case "STRING":
				string[] parts = patch.Split('>');
				finalResult = code.Replace(parts[0], parts[1]);
				break;
			case "LINENUMBER_REPLACE": 
				int firstNewline = patch.IndexOf("\n");
				int insertPosition = int.Parse(patch.Substring(2, firstNewline - 1));
				string[] lines = code.Split('\n');
				lines[insertPosition - 1] = patch.Substring(firstNewline);
				finalResult = string.Join("\n", lines);
				break;
			case "LINENUMBER": 
				firstNewline = patch.IndexOf("\n");
				insertPosition = int.Parse(patch.Substring(2, firstNewline - 1));
				lines = code.Split('\n');
				lines[insertPosition - 1] = patch.Substring(firstNewline) + "\n" + lines[insertPosition - 1];
				finalResult = string.Join("\n", lines);
				break;
			default:
				finalResult = code;
				break;
		};
		ImportGMLString(codeEntryName, finalResult);
	}
}





// Duplicating generic objects

UndertaleGameObject obj_generic_item0 = Data.GameObjects.ByName("obj_generic_item0");
for (int i = 1; i < 64; i++) {
	cloneObject(obj_generic_item0, "obj_generic_item" + i.ToString());
}


UndertaleGameObject cloneObject(UndertaleGameObject obj, string newName) {
	// copied with some modifications from GameObjectCopyInternal.csx

	UndertaleGameObject donorOBJ = obj;
	UndertaleGameObject nativeOBJ = new UndertaleGameObject();
	nativeOBJ.Name = Data.Strings.MakeString(newName);
	Data.GameObjects.Add(nativeOBJ);
	nativeOBJ.Visible = donorOBJ.Visible;
	nativeOBJ.Solid = donorOBJ.Solid;
	nativeOBJ.Depth = donorOBJ.Depth;
	nativeOBJ.Persistent = donorOBJ.Persistent;
	nativeOBJ.ParentId = donorOBJ.ParentId;
	if (donorOBJ.TextureMaskId != null)
		nativeOBJ.TextureMaskId = Data.Sprites.ByName(donorOBJ.TextureMaskId.Name.Content);

	nativeOBJ.Events.Clear();
	for (var i = 0; i < donorOBJ.Events.Count; i++)
	{
		UndertalePointerList<UndertaleGameObject.Event> newEvent = new UndertalePointerList<UndertaleGameObject.Event>();
		foreach (UndertaleGameObject.Event evnt in donorOBJ.Events[i])
		{
			UndertaleGameObject.Event newevnt = new UndertaleGameObject.Event();
			foreach (UndertaleGameObject.EventAction donorACT in evnt.Actions)
			{
				UndertaleGameObject.EventAction nativeACT = new UndertaleGameObject.EventAction();
				newevnt.Actions.Add(nativeACT);
				nativeACT.LibID = donorACT.LibID;
				nativeACT.ID = donorACT.ID;
				nativeACT.Kind = donorACT.Kind;
				nativeACT.UseRelative = donorACT.UseRelative;
				nativeACT.IsQuestion = donorACT.IsQuestion;
				nativeACT.UseApplyTo = donorACT.UseApplyTo;
				nativeACT.ExeType = donorACT.ExeType;
				nativeACT.ActionName = donorACT.ActionName;
				nativeACT.CodeId = donorACT.CodeId;
				nativeACT.ArgumentCount = donorACT.ArgumentCount;
				nativeACT.Who = donorACT.Who;
				nativeACT.Relative = donorACT.Relative;
				nativeACT.IsNot = donorACT.IsNot;
				nativeACT.UnknownAlwaysZero = donorACT.UnknownAlwaysZero;
			}
			newevnt.EventSubtype = evnt.EventSubtype;
			newEvent.Add(newevnt);
		}
		nativeOBJ.Events.Add(newEvent);
	}
	return nativeOBJ;
}


Data.GeneralInfo.FileName = modloaderData.GeneralInfo.FileName;
Data.GeneralInfo.Name = modloaderData.GeneralInfo.Name;
Data.GeneralInfo.DisplayName = modloaderData.GeneralInfo.DisplayName;

ScriptMessage("Done! Nubby's Forgery has been merged!");