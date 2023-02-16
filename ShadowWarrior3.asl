/*
Scanning best practices

Loading
Always in SW3.exe. Goes from 1-2 and then quickly hits 39 for the "Press any button to continue" part of loading.
Best just to scan for changed value between game/loading, and use unchanged for in game ONLY. since the load value changes cant be seen on the load screen.
When the screen says "Press any key" you can mouse over to cheat engine and scan for 39

Mission
UTF-16 all the time. Ends in 0x0. Here are a few sample missions to scan for
/Game/Maps/Levels/StartLevel
/Game/Maps/Levels/03_Way_To_Motoko/03_Way_To_Motoko
/Game/Maps/Levels/05_Dam/05_Dam

Cutscene
All updates before 1.06 this was stored in bink2w64.dll but 1.06 deleted it. Now its stored in the exe - still 1 during cutscene and 0 elsewhere
*/

state("SW3", "Steam v1.00")
{
    int loading         : 0x4C6826C;
    string150 mission   : 0x04E059B0, 0xE00, 0x30, 0xF8, 0x0; 
    int cutsceneState   : "bink2w64.dll", 0x56310; 
}

state("SW3", "Steam v1.05")
{
    int loading         : 0x04DA7450, 0x1DC;
    string150 mission   : 0x04DBE9F0, 0x180, 0x30, 0xF8, 0x0; 
    int cutsceneState   : "bink2w64.dll", 0x56310; 
}

state("SW3", "Steam v1.06")
{
    int loading         : 0x4CE58D4;
    string150 mission   : 0x04E25290, 0x180, 0x30, 0xF8, 0x0; 
    int cutsceneState   : 0x4E51E80;
}

init
{
switch (modules.First().ModuleMemorySize) 
    {
        case 87080960: 
            version = "Steam v1.00";
            break;
        case 86740992: 
            version = "Steam v1.05";
            break;
        case 87187456: 
            version = "Steam v1.06";
            break;
        default:
        print("Unknown version detected");
        return false;
    }
}

startup
{
    // Checks if the current comparison is set to Real Time
    // Asks user to change to Game Time if LiveSplit is currently set to Real Time.
    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {
        var timingMessage = MessageBox.Show (
            "This game uses Time without Loads (Game Time) as the main timing method.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time?",
            "LiveSplit | Shadow Warrior 3",
            MessageBoxButtons.YesNo, MessageBoxIcon.Question
        );
        if (timingMessage == DialogResult.Yes)
            timer.CurrentTimingMethod = TimingMethod.GameTime;
    }
}

onStart
{
    // This is part of a "cycle fix", makes sure the timer always starts at 0.00
    timer.IsGameTimePaused = true;
}

start
{
    // Start the timer when the loaded map changes from the Main Menu to Chapter 1 during the load screen
    return (current.mission == "/Game/Maps/Levels/01_The_Plan/01_The_Plan" && old.mission == "/Game/Maps/Levels/StartLevel");
}

isLoading
{
    return current.loading != 0 || current.cutsceneState == 1;
}

update
{
    //DEBUG CODE
    //print(modules.First().ModuleMemorySize.ToString());
    //print(current.mission.ToString());
} 

split
{
    return current.mission != old.mission && current.mission != "/Game/Maps/Levels/StartLevel";
}

split 
{ 	return
        (
            (current.mission.Contains("03_Way_To_Motoko"))             && (old.mission.Contains("01_The_Plan")) ||
            (current.mission.Contains("04_Motokos_Cave"))              && (old.mission.Contains("03_Way_To_Motoko")) ||
            (current.mission.Contains("05_Dam"))                       && (old.mission.Contains("04_Motokos_Cave")) ||
            (current.mission.Contains("05_B_Cave"))                    && (old.mission.Contains("05_Dam")) ||
            (current.mission.Contains("06_DragonNest"))                && (old.mission.Contains("05_B_Cave")) ||
            (current.mission.Contains("06_DN_BossGuardian"))          && (old.mission.Contains("06_DragonNest")) ||
            (current.mission.Contains("06_Dragon_Nest_Egg_Chase"))     && (old.mission.Contains("06_DN_BossGuardian")) ||
            (current.mission.Contains("07_Hot_Springs"))               && (old.mission.Contains("06_Dragon_Nest_Egg_Chase")) ||
            (current.mission.Contains("09_Hojis_Portal"))              && (old.mission.Contains("07_Hot_Springs")) ||
            (current.mission.Contains("15_Finding_Hoji"))              && (old.mission.Contains("09_Hojis_Portal")) ||
            (current.mission.Contains("15_Frozen_Forest"))             && (old.mission.Contains("15_Finding_Hoji")) ||
            (current.mission.Contains("14_Finding_Zilla"))             && (old.mission.Contains("15_Frozen_Forest")) ||
            (current.mission.Contains("16_Frozen_World"))              && (old.mission.Contains("14_Finding_Zilla")) ||
            (current.mission.Contains("16_Frozen_World_Part2"))        && (!old.mission.Contains("16_Frozen_World_Part2")) ||
            (current.mission.Contains("17_Dragon_Belly"))              && (old.mission.Contains("16_Frozen_World_Part2")) ||
            (current.mission.Contains("DB_Boss_Kraken"))               && (!old.mission.Contains("DB_Boss_Kraken"))
        );
	}	 


exit
{
    timer.IsGameTimePaused = true;
}
