/**
 * MicroTF2 - Minigame 6
 * 
 * Say the Word!
 */

#define MINIGAME6_SAYTEXTANSWERS_CAPACITY 128

char Minigame6_SayTextAnswers[MINIGAME6_SAYTEXTANSWERS_CAPACITY][64];
int Minigame6_SayTextAnswerCount; 

char Minigame6_SayTextAnswer[64];
bool Minigame6_HasBeenAnswered = false;

public void Minigame6_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame6_OnMinigameSelectedPre);

	RegConsoleCmd("say", Command_MinigameSixSay);
	RegConsoleCmd("say_team", Command_MinigameSixSay);

	Minigame6_LoadAnswers();
}

public void Minigame6_OnMinigameSelectedPre()
{
	if (MinigameID == 6)
	{
		Format(Minigame6_SayTextAnswer, sizeof(Minigame6_SayTextAnswer), Minigame6_SayTextAnswers[GetRandomInt(0, Minigame6_SayTextAnswerCount - 1)]);
		Minigame6_HasBeenAnswered = false;
	}
}

public void Minigame6_GetDynamicCaption(int client)
{
	Player player = new Player(client);
	
	if (player.IsInGame)
	{
		char text[64];
 		Format(text, sizeof(text), "%s\n%s", MinigameCaption[client], Minigame6_SayTextAnswer);	
 		MinigameCaption[client] = text;
	}
}

public Action Command_MinigameSixSay(int client, int args)
{
	if (IsMinigameActive && MinigameID == 6)
	{
		char text[192];
		if (GetCmdArgString(text, sizeof(text)) < 1)
		{
			return Plugin_Continue;
		}

		if (IsPlayerParticipant[client])
		{
			int startidx;
			if (text[strlen(text)-1] == '"') 
			{
				text[strlen(text)-1] = '\0';
			}

			startidx = 1;
			char message[192];
			BreakString(text[startidx], message, sizeof(message));
	
			if (strcmp(message, Minigame6_SayTextAnswer, false) == 0)
			{
				ClientWonMinigame(client);

				if (!Minigame6_HasBeenAnswered)
				{
					CPrintToChatAllEx(client, "%s{teamcolor}%N {green}answered first! (Bonus Point!)", PLUGIN_PREFIX, client);

					PlayerScore[client]++;
					Minigame6_HasBeenAnswered = true;
				}

				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

public bool Minigame6_LoadAnswers()
{
	char manifestPath[128];
	BuildPath(Path_SM, manifestPath, sizeof(manifestPath), "data/microtf2/Minigame6.Answers.txt");

	Handle file = OpenFile(manifestPath, "r"); 

	if (file == INVALID_HANDLE)
	{
		LogError("Failed to open Minigame6.Answers.txt in data/microtf2. This minigame has been disabled.");
		return false;
	}

	char line[64];

	while (ReadFileLine(file, line, sizeof(line)))
	{
		if (Minigame6_SayTextAnswerCount >= MINIGAME6_SAYTEXTANSWERS_CAPACITY)
		{
			LogError("Hit the hardcoded limit of answers for Minigame6. If you really want to add more, recompile the plugin with the limit changed.");
			break;
		}

		TrimString(line);

		if (strlen(line) == 0)
		{
			continue;
		}

		Minigame6_SayTextAnswers[Minigame6_SayTextAnswerCount] = line;
		Minigame6_SayTextAnswerCount++;
	}

	CloseHandle(file);

	LogMessage("Minigame6: Loaded %i answers", Minigame6_SayTextAnswerCount);

	return true;
}