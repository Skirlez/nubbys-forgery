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
	if (Data.GameObjects.ByName(gameObject.Name.Content) != null)
		continue;
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

	// Same default settings as editor
	Underanalyzer.Decompiler.DecompileSettings settings = new();
	settings.UnknownArgumentNamePattern = "arg{0}";
	settings.RemoveSingleLineBlockBraces = true;
	settings.EmptyLineAroundBranchStatements = true;
	settings.EmptyLineBeforeSwitchCases = true;

	GlobalDecompileContext globalContext = new GlobalDecompileContext(Data);

	CodeImportGroup importGroup = new(Data, globalContext, settings);

	string targetPattern = @"// TARGET: ([^\n\r]+)";
	string[] sections = Regex.Split(patches, targetPattern);

	for (int i = 1; i < sections.Length; i += 2) {
		string code = GetDecompiledText(entry, globalContext, settings);
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
		
		importGroup.QueueReplace(codeEntryName, finalResult);
		importGroup.Import();
	}
	
}





// Duplicating generic objects

UndertaleGameObject obj_generic_item0 = Data.GameObjects.ByName("obj_generic_item0");
UndertaleGameObject obj_generic_perk0 = Data.GameObjects.ByName("obj_generic_perk0");
UndertaleGameObject obj_generic_supervisor0 = Data.GameObjects.ByName("obj_generic_supervisor0");
for (int i = 1; i < 1024; i++) {
	cloneObject(obj_generic_item0, "obj_generic_item" + i.ToString());
	cloneObject(obj_generic_perk0, "obj_generic_perk" + i.ToString());
	cloneObject(obj_generic_supervisor0, "obj_generic_supervisor" + i.ToString());
}


UndertaleGameObject cloneObject(UndertaleGameObject sourceObj, string newName) {
	// copied with some modifications from GameObjectCopyInternal.csx

	UndertaleGameObject obj = new UndertaleGameObject();
	obj.Name = Data.Strings.MakeString(newName);
	Data.GameObjects.Add(obj);
	obj.Visible = sourceObj.Visible;
	obj.Solid = sourceObj.Solid;
	obj.Depth = sourceObj.Depth;
	obj.Persistent = sourceObj.Persistent;
	obj.ParentId = sourceObj.ParentId;
	obj.Events.Clear();
	for (var i = 0; i < sourceObj.Events.Count; i++)
	{
		UndertalePointerList<UndertaleGameObject.Event> newEvent = new UndertalePointerList<UndertaleGameObject.Event>();
		foreach (UndertaleGameObject.Event evnt in sourceObj.Events[i])
		{
			UndertaleGameObject.Event newevnt = new UndertaleGameObject.Event();
			foreach (UndertaleGameObject.EventAction sourceAction in evnt.Actions)
			{
				UndertaleGameObject.EventAction action = new UndertaleGameObject.EventAction();
				newevnt.Actions.Add(action);
				action.LibID = sourceAction.LibID;
				action.ID = sourceAction.ID;
				action.Kind = sourceAction.Kind;
				action.UseRelative = sourceAction.UseRelative;
				action.IsQuestion = sourceAction.IsQuestion;
				action.UseApplyTo = sourceAction.UseApplyTo;
				action.ExeType = sourceAction.ExeType;
				action.ActionName = sourceAction.ActionName;
				action.CodeId = sourceAction.CodeId;
				action.ArgumentCount = sourceAction.ArgumentCount;
				action.Who = sourceAction.Who;
				action.Relative = sourceAction.Relative;
				action.IsNot = sourceAction.IsNot;
				action.UnknownAlwaysZero = sourceAction.UnknownAlwaysZero;
			}
			newevnt.EventSubtype = evnt.EventSubtype;
			newEvent.Add(newevnt);
		}
		obj.Events.Add(newEvent);
	}
	return obj;
}


// Changes the save location to nubby's forgery
Data.GeneralInfo.Name = modloaderData.GeneralInfo.Name;


ScriptMessage("Done! Nubby's Forgery has been merged!");