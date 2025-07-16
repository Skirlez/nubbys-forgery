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
enum PatchType {
	WriteBefore,
	WriteAfter,
	WriteReplace
}
Dictionary<string, PatchType> writeFunctionTypes = new Dictionary<string, PatchType>
{
	{"write_before", PatchType.WriteBefore},
	{"write_replace", PatchType.WriteReplace},
	{"write_after", PatchType.WriteAfter}
};
class Patch {
	public string text;
	public bool critical;
	public string owner;
	public PatchType type;
	public Patch(PatchType type, string text, bool critical, string owner) {
		this.text = text;
		this.type = type;
		this.critical = critical;
		this.owner = owner;
	}
}

var allPatches = new Dictionary<string, Dictionary<int, List<Patch>>>();

// Same default settings as editor
Underanalyzer.Decompiler.DecompileSettings settings = new();
settings.UnknownArgumentNamePattern = "arg{0}";
settings.RemoveSingleLineBlockBraces = true;
settings.EmptyLineAroundBranchStatements = true;
settings.EmptyLineBeforeSwitchCases = true;

GlobalDecompileContext globalContext = new GlobalDecompileContext(Data);



// Apply the patches
applyPatches(modloaderPatchesPath);

ScriptMessage("Done! Nubby's Forgery has been merged!");


void applyPatches(string path) {
	foreach (string file in Directory.GetFiles(modloaderPatchesPath, "*.gmlp", SearchOption.AllDirectories)) {
		string patchfile = File.ReadAllText(file);
		try {
			executePatchFile(patchfile, "modloader");
		}
		catch (Exception e) {
			string relativePath = Path.GetRelativePath(modloaderPatchesPath, file);
			Console.WriteLine($"Error in file {relativePath}: {e.Message}");
		}
	}

	CodeImportGroup importGroup = new(Data, globalContext, settings);

	foreach (string file in allPatches.Keys) {
		ScriptMessage(file);
		UndertaleCode codeFile = Data.Code.ByName(file);
		string code = GetDecompiledText(codeFile, globalContext, settings);
		string[] lines = code.Split('\n');
		Dictionary<int, List<Patch>> filePatches = allPatches[file];
		foreach(int line in filePatches.Keys) {
			List<Patch> linePatches = filePatches[line];

			// TODO: The order in which we iterate on this list of patches must be consistent
			// TODO: patch conflict detection
			foreach (Patch patch in linePatches) {
				switch (patch.type) {
					case PatchType.WriteBefore:
						lines[line] = patch.text + "\n" + lines[line];
						break;
					case PatchType.WriteAfter:
						lines[line] = lines[line] + "\n" + patch.text;
						break;
					case PatchType.WriteReplace:
						lines[line] = patch.text;
						break;
					default:
						break;
				}
			}

		}
		
		string finalResult = string.Join("\n", lines);
		importGroup.QueueReplace(file, finalResult);
		importGroup.Import();
	}

}


class Token {
	public int lineNumber;
	public Token(int lineNumber) {
		this.lineNumber = lineNumber;
	}
}
class NumberToken : Token {
	public int number;
	public NumberToken(int number, int lineNumber) : base(lineNumber) {
		this.number = number;
	}
}

class NameToken : Token {
	public string name;
	public NameToken(string name, int lineNumber) : base(lineNumber) {
		this.name = name;
	}
}
class SectionToken : Token {
	public string section;
	public SectionToken(string section, int lineNumber) : base(lineNumber) {
		this.section = section;
	}
}
class EqualsToken : Token { 
	public EqualsToken(int lineNumber) : base(lineNumber) { }
}
class ParensStartToken : Token { 
	public ParensStartToken(int lineNumber) : base(lineNumber) { }
}
class ParensEndToken : Token {
	public ParensEndToken(int lineNumber) : base(lineNumber) { }
}

class StringToken : Token {
	public string text;
	public StringToken(string text, int lineNumber) : base(lineNumber) {
		this.text = text;
	}
}

Token[] tokenize(string patch) {
	List<Token> tokens = new List<Token>();
	int lineNumber = 1;
	string build = "";
	for (int i = 0; i < patch.Length; i++) {
		char c = patch[i];
		if (c == '/' && i + 1 < patch.Length) {
			if (patch[i + 1] == '/') {
				i += 2;
				while (i < patch.Length && patch[i] != '\n')
					i++;
				continue;
			}
			else if (patch[i + 1] == '*') {
				i += 2;
				while (i + 1 < patch.Length && !(patch[i] == '*' && patch[i + 1] == '/'))
					i++;
				i++;
				continue;
			}
		}
		if (char.IsWhiteSpace(c)) {
			if (build != "") {
				tokens.Add(new NameToken(build, lineNumber));
				build = "";
			}
			if (c == '\n')
				lineNumber++;
			continue;
		}
		if (c == ':') {
			if (build != "") {
				tokens.Add(new SectionToken(build, lineNumber));
				build = "";
			}
			continue;
		}
		if (build == "" && (c == '-' || c == '+' || char.IsDigit(c))) {
			build += c;
			i++;
			while (i < patch.Length && char.IsDigit(patch[i])) {
				build += patch[i];
				i++;
			}
			if (build == "-" || build == "+") {
				// TODO error
			}
			else {
				int number = int.Parse(build);
				tokens.Add(new NumberToken(number, lineNumber));
			}
			build = "";
			i--;
			continue;
		}

		// TODO optimize
		if (c == '=') {
			if (build != "") {
				tokens.Add(new NameToken(build, lineNumber));
				build = "";
			}
			tokens.Add(new EqualsToken(lineNumber));
			continue;
		}
		if (c == '(') {
			if (build != "") {
				tokens.Add(new NameToken(build, lineNumber));
				build = "";
			}
			tokens.Add(new ParensStartToken(lineNumber));
			continue;
		}
		if (c == ')') {
			if (!string.IsNullOrWhiteSpace(build)) {
				tokens.Add(new NameToken(build, lineNumber));
				build = "";
			}
			tokens.Add(new ParensEndToken(lineNumber));
			continue;
		}

		if (c == '\'') {
			if (!string.IsNullOrWhiteSpace(build)) {
				tokens.Add(new NameToken(build, lineNumber));
			}
			int lineNumberStart = lineNumber;
			build = "";
			string text = "";
			i++;
			while (i < patch.Length && !(patch[i - 1] != '\\' && patch[i] == '\'')) {
				if (patch[i] == '\n')
					lineNumber++;
				text += patch[i];
				i++;
			}
			if (i >= patch.Length) {
				// TODO ERROR
				continue;	
			}
			if (!string.IsNullOrWhiteSpace(text)) {
				tokens.Add(new StringToken(text, lineNumberStart));
			}
			continue;
		}
		build += c;
	}
	return tokens.ToArray();
}

void executePatchFile(string patchfile, string owner) {
	Token[] tokens = tokenize(patchfile);
	int pos = 0;
	while (pos < tokens.Length) {
		int lastLineNumber = tokens[pos].lineNumber;
		if (tokens[pos] is SectionToken metaSectionToken && metaSectionToken.section == "meta") {
			(string target, bool critical, pos) = executePatchMetadata(tokens, pos + 1);
			if (pos < tokens.Length || tokens[pos] is SectionToken patchSectionToken && patchSectionToken.section == "patch") {
				pos = executePatch(tokens, pos + 1, target, critical, owner);
			}
			else {
				throw new Exception($"Incomplete patch; meta section without patch section");
			}
		}
		else {
			throw new Exception($"Expected \"meta:\" section at start of patch (line {lastLineNumber})");
		}
	}
}


(string target, bool critical, int pos) executePatchMetadata(Token[] tokens, int pos) {
	bool critical = true;
	string target = "";
	while (pos < tokens.Length) {
		Token token = tokens[pos];
		if (token is NameToken nameToken) {
			switch (nameToken.name) {
				case "critical": {
					Token equalsToken = expect(tokens, pos + 1, typeof(EqualsToken), nameToken.lineNumber);
					pos++;
					NameToken valueToken = (NameToken)expect(tokens, pos + 1, typeof(NameToken), equalsToken.lineNumber);
					pos++;
					if (valueToken.name != "true" && valueToken.name != "false") {
						throw new Exception($"At line {valueToken.lineNumber}: Expected \"true\" or \"false\"");
					}
					critical = valueToken.name == "true";
					break;
				}
				case "target": {
					Token equalsToken = expect(tokens, pos + 1, typeof(EqualsToken), nameToken.lineNumber);
					pos++;
					NameToken targetToken = (NameToken)expect(tokens, pos + 1, typeof(NameToken), equalsToken.lineNumber);
					pos++;
					if (Data.Code.ByName(targetToken.name) is null)
						throw new Exception($"At line {targetToken.lineNumber}: code file {targetToken.name} does not exist");
					target = targetToken.name;
					break;
				}
				default:
					throw new Exception($"At line {nameToken.lineNumber}: invalid metadata name {nameToken.name}");
					break;
			}
		}
		else {
			break; // leave as soon as we stop seeing name tokens
		}
		pos++;
	}
	return (target, critical, pos);
}

int executePatch(Token[] tokens, int pos, string target, bool critical, string owner) {
	string code = GetDecompiledText(Data.Code.ByName(target), globalContext, settings);
	string[] lines = code.Split('\n');

	Dictionary<int, List<Patch>> filePatches;
	if (!allPatches.ContainsKey(target)) {
		filePatches = new Dictionary<int, List<Patch>>();
		allPatches[target] = filePatches;
	}
	else {
		filePatches = allPatches[target];
	}
	int filePos = 0;
	while (pos < tokens.Length) {
		Token token = tokens[pos];
		if (token is SectionToken) {
			break;
		}
		if (token is NameToken nameToken) {
			switch (nameToken.name) {
				case "move_to_end": {
					Token startToken = expect(tokens, pos + 1, typeof(ParensStartToken), nameToken.lineNumber);
					pos++;
					Token endToken = expect(tokens, pos + 1, typeof(ParensEndToken), startToken.lineNumber);
					pos++;
					filePos = lines.Length - 1;
					break;
				}
				case "move_to":
				case "move": {
					Token startToken = expect(tokens, pos + 1, typeof(ParensStartToken), nameToken.lineNumber);
					pos++;
					NumberToken numberToken = (NumberToken)expect(tokens, pos + 1, typeof(NumberToken), startToken.lineNumber);
					pos++;
					Token endToken = expect(tokens, pos + 1, typeof(ParensEndToken), numberToken.lineNumber);
					pos++;
					
					if (nameToken.name == "move_to")
						filePos = numberToken.number - 1;
					else
						filePos += numberToken.number;
				
					break;
				}
				case "find_line_with": {
					Token startToken = expect(tokens, pos + 1, typeof(ParensStartToken), nameToken.lineNumber);
					pos++;
					StringToken stringToken = (StringToken)expect(tokens, pos + 1, typeof(StringToken), startToken.lineNumber);
					pos++;
					Token endToken = expect(tokens, pos + 1, typeof(ParensEndToken), stringToken.lineNumber);
					pos++;
					
					for (int i = filePos; i < lines.Length; i++) {
						if (lines[i].Contains(stringToken.text)) {
							filePos = i;
							break;
						}
					}
					break;
				}
				case "reverse_find_line_with": {
					Token startToken = expect(tokens, pos + 1, typeof(ParensStartToken), nameToken.lineNumber);
					pos++;
					StringToken stringToken = (StringToken)expect(tokens, pos + 1, typeof(StringToken), startToken.lineNumber);
					pos++;
					Token endToken = expect(tokens, pos + 1, typeof(ParensEndToken), stringToken.lineNumber);
					pos++;
					
					for (int i = filePos; i >= 0; i--) {
						if (lines[i].Contains(stringToken.text)) {
							filePos = i;
							break;
						}
					}
					break;
				}
				case "write_before":
				case "write_replace":
				case "write_after": {
					Token startToken = expect(tokens, pos + 1, typeof(ParensStartToken), nameToken.lineNumber);
					pos++;
					StringToken stringToken = (StringToken)expect(tokens, pos + 1, typeof(StringToken), startToken.lineNumber);
					pos++;
					Token endToken = expect(tokens, pos + 1, typeof(ParensEndToken), stringToken.lineNumber);
					pos++;
					
					List<Patch> linePatches;
					if (!filePatches.ContainsKey(filePos)) {
						linePatches = new List<Patch>();
						filePatches[filePos] = linePatches;
					}
					else
						linePatches = filePatches[filePos];
					
					PatchType type = writeFunctionTypes[nameToken.name];
					linePatches.Add(new Patch(type, stringToken.text, critical, owner));
					break;
				}
				default:
					throw new Exception($"At line {nameToken.lineNumber}: unknown operation {nameToken.name}");
			}
		}
		else {
			throw new Exception($"Unexpected token {token.GetType().Name} at line {token.lineNumber}");
		}
		pos++;
	}
	return pos;
}

Token expect(Token[] tokens, int pos, Type type, int lastLineNumber) {
	if (pos >= tokens.Length) {
		throw new Exception($"At line {lastLineNumber}: Expected {type.Name}, found end of file");
	}
	Token token = tokens[pos];
	if (!type.IsInstanceOfType(token)) {
		throw new Exception($"At line {token.lineNumber}: Expected {type.Name}, found {token.GetType().Name}");
	}
	return token;
}

