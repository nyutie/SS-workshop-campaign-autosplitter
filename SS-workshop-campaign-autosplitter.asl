// state("ThankYouVeryCool-Win64-Shipping", "epic patch 5.2") {
//     float fullTimer: 0x5DCAF40, 0x118, 0xB68;
//     bool isOnMainMenu: 0x5C838E0, 0x8F0, 0xA0, 0x3E0, 0x320;
//     // int campaignLevelIndex:
//     // int stage:
//     // uint isFFx4WhenLevelIsNewType:
// }

state("ThankYouVeryCool-Win64-Shipping", "steam patch 5.1") {
    float fullTimer: 0x5B1A2C0, 0x118, 0xB68;
    bool isOnMainMenu: 0x59D2C60, 0x2190, 0x0, 0xEA0, 0x27C;
    int campaignLevelIndex: 0x5B1A2C0, 0x118, 0xD80, 0x2F8;
    int stage: 0x5B1A2C0, 0x118, 0xD80, 0x2E0, 0x360;
    uint isFFx4WhenLevelIsNewType: 0x5B1A2C0, 0x118, 0xD80, 0x2E0, 0x398; // I know, it's dirty but it works. if you got a better way dm me
}

state("ThankYouVeryCool-Win64-Shipping", "steam patch 5.2") {
    float fullTimer: 0x5B1A300, 0x118, 0xB68;
    bool isOnMainMenu: 0x59D2CA0, 0x8F0, 0xA0, 0x3E0, 0x320;
    int campaignLevelIndex: 0x5B1A300, 0x118, 0xD80, 0x2F8;
    int stage: 0x5B1A300, 0x118, 0xD80, 0x2E0, 0x360;
    uint isFFx4WhenLevelIsNewType: 0x5B1A300, 0x118, 0xD80, 0x2E0, 0x398; // I know, it's dirty but it works. if you got a better way dm me 
}

startup
{
    settings.Add("useStageSplits", true, "Split on stage change");

    if(timer.CurrentTimingMethod == TimingMethod.RealTime) // copied this from somewhere lmao
    {
        var timingMessage = MessageBox.Show
        (
            "This game uses Game Time (time without loads) as the main timing method.\n"+
            "LiveSplit is currently set to show Real Time (time INCLUDING loads).\n"+
            "Would you like the timing method to be set to Game Time for you?",
            "SS-workshop-campaign-autosplitter | LiveSplit",
            MessageBoxButtons.YesNo,
            MessageBoxIcon.Question
        );
        if (timingMessage == DialogResult.Yes) timer.CurrentTimingMethod = TimingMethod.GameTime;
    }
}

init
{
    string MD5Hash;
    using (var md5 = System.Security.Cryptography.MD5.Create())
    using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
    MD5Hash = md5.ComputeHash(s).Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);

    switch (MD5Hash)
    {
        // case "37C6CE6B3C0C0399424250CC7EF3457F":
        //     version = "epic patch 5.2";
        //     break;
        case "A8C57AD035ED26B6E1DCED0499EBFA22":
            version = "steam patch 5.1";
            vars.SaveOffsetPath = new DeepPointer(0x5B15EF8, 0x130, 0x38, 0x70, 0x459);
            break;
        case "76EAB92EF3754360BAB05B7D535C6956":
            version = "steam patch 5.2";
            break;
        default:
            MessageBox.Show
            (
                "Unsupported version of the game! If you're on GOG, sorry, I don't have it.\n" +
                "If you're on Steam/Epic, I'm probably already working on the update!\n\n" +
                "If you have any questions you can find me on the official Greylock Discord server, or the official SS/EPN speedrun Discord server.\n\n" +
                "modules.first().ModuleMemorySize: 0x" + modules.First().ModuleMemorySize.ToString("X") + "\n" +
                "new FileInfo(modules.First().FileName).Length): 0x" + new FileInfo(modules.First().FileName).Length.ToString("X") + "\n" +
                "MD5Hash: " + MD5Hash,
                "SS-workshop-campaign-autosplitter | LiveSplit",
                MessageBoxButtons.OK,
                MessageBoxIcon.Warning
            );
            print("Hash is: " + MD5Hash);
            return false;
    }
}

start
{
    if (current.isOnMainMenu || !(current.fullTimer < 0.1f && current.fullTimer > 0f)) {
        return false;
    }

    if (current.isFFx4WhenLevelIsNewType != 0xFFFFFFFF) {
        MessageBox.Show
        (
            "This level seems to be the old type. This autosplitter isn't meant for campaign levels, and will not work.\n" +
            "It should work for any single bonus or workshop level.",
            "SS-workshop-campaign-autosplitter | LiveSplit",
            MessageBoxButtons.OK,
            MessageBoxIcon.Warning
        );
        return false;
    }

    if (current.stage == 0)
    {
        return true;
    }
}

split
{
    if (current.campaignLevelIndex == old.campaignLevelIndex + 1)
    {
        return true;
    }

    if (settings["useStageSplits"] && current.stage == old.stage + 1)
    {
        return true;
    }
}

reset
{
    if (current.isOnMainMenu || old.fullTimer > current.fullTimer)
    {
        return true;
    }

    if (settings["useStageSplits"] && current.campaignLevelIndex == 0 && old.stage > current.stage)
    {
        return true;
    }
}

isLoading
{
    if (current.fullTimer == old.fullTimer)
    {
        return true;
    }

    return false;
}

gameTime
{
    return TimeSpan.FromSeconds(current.fullTimer);
}
