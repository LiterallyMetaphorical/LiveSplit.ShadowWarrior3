
state("SW3")
{
    // Always in SW3.exe. Goes from 1-2 and then quickly hits 39 for the "Press any button to continue" part of loading.
    int loading         : 0x04DA7450, 0x1DC;
    
    // UTF-16 all the time. Tends to start from the same address, and ends in 0x0. Everything inbetween can change between updates.
    string150 objective : 0x04DBE9F0, 0x180, 0x30, 0xF8, 0x0; 
    
    // Shouldn't break on updates.
    int cutsceneState   : "bink2w64.dll", 0x56310; 
}

init 
{
    switch (modules.First().ModuleMemorySize)
    {
        case 0x100000: break; //try 83000
        default: return;
    }

    // Grab the autosplitter from splits/layout
    var aslCmp = timer.Layout.Components.Append((timer.Run.AutoSplitter ?? new AutoSplitter()).Component)
                 .FirstOrDefault(c => c.GetType().Name == "ASLComponent");

    if (aslCmp == null)
        return;

    var script = aslCmp.GetType().GetProperty("Script").GetValue(aslCmp);
    script.GetType().GetField("_game", BindingFlags.NonPublic | BindingFlags.Instance).SetValue(script, null);
}

startup
{
    refreshRate = 30;

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
    return (current.objective == "/Game/Maps/Levels/01_The_Plan/01_The_Plan" && old.objective == "/Game/Maps/Levels/StartLevel");
}

isLoading
{
    return current.loading != 0 || current.cutsceneState == 1;
}

update
{
 print(current.objective.ToString());
} 

split
{
    return current.objective != old.objective && current.objective != "/Game/Maps/Levels/StartLevel";
}

exit
{
    timer.IsGameTimePaused = true;
}
