state("SW3")
{
    bool loading        : 0x492D678;
    string100 objective : 0x04E05BF0, 0x8C8, 0x0; //UTF-16 all the time. Tends to start from the same address, and ends in 0x0. Everything inbetween can change between updates
    int cutsceneState : "bink2w64.dll", 0x56310;
}

init 
{
    // Basically finding and naming the exe we want to target as I understand it
    switch(modules.First().ModuleMemorySize)
    {
	case 536576 :
        version = "wrongEXE";
        break;
    }
    
    // Now using the exe we found earlier, we can tell livesplit to leave it alone and find the correct exe we want to read from
    if (version == "wrongEXE") {
        var allComponents = timer.Layout.Components;
        // Grab the autosplitter from splits
        if (timer.Run.AutoSplitter != null && timer.Run.AutoSplitter.Component != null) {
            allComponents = allComponents.Append(timer.Run.AutoSplitter.Component);
        }
        foreach (var component in allComponents) {
            var type = component.GetType();
            if (type.Name == "ASLComponent") {
                // Could also check script path, but renaming the script breaks that, and
                //  running multiple autosplitters at once is already just asking for problems
                var script = type.GetProperty("Script").GetValue(component);
                script.GetType().GetField(
                    "_game",
                    BindingFlags.NonPublic | BindingFlags.Instance
                ).SetValue(script, null);
            }
        }
        return;
    }
}

startup
  {
        // This is part of a "cycle fix" I got from Ero, makes sure the timer always starts at 0.00
	    vars.TimerStart = (EventHandler) ((s, e) => timer.IsGameTimePaused = true);
        timer.OnStart += vars.TimerStart;
	  	refreshRate=30;

        // Checks if the current comparison is set to Real Time
		if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    // Asks user to change to Game Time if LiveSplit is currently set to Real Time.
        {        
        var timingMessage = MessageBox.Show (
            "This game uses Time without Loads (Game Time) as the main timing method.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time?",
            "LiveSplit | Shadow Warrior 3",
            MessageBoxButtons.YesNo,MessageBoxIcon.Question
        );
        
        if (timingMessage == DialogResult.Yes)
            {
                timer.CurrentTimingMethod = TimingMethod.GameTime;
            }
        }
}   

start
{
    //Start the timer when the loaded map changes from the Main Menu to Chapter 1 during the load screen
    return (current.objective == "/Game/Maps/Levels/01_The_Plan/01_The_Plan" && old.objective == "/Game/Maps/Levels/StartLevel");
}

split
{
    return current.objective != old.objective && current.objective != "/Game/Maps/Levels/StartLevel";
}

/*update
{
    print(current.cutsceneState.ToString());
}*/


isLoading
{
    return !current.loading || current.cutsceneState == 1;
}

shutdown
{
    timer.OnStart -= vars.TimerStart;
}

exit
{
	timer.IsGameTimePaused = true;
}