package frc.aegis.scoutingapp;

public class TeamEntry {
    private int teamNum;
    private int round;
    private int points;
    private int habClimb;
    private int habStart;
    private int hatchCnt;
    private int cargoCnt;
    private int preload; // 0 - nothing; 1-cargo; 2-hatch;

    private boolean color; //red is false, blue is true;
    private boolean cargo;
    private boolean hatch;
    private boolean yellow;
    private boolean red;
    private boolean descored;
    private boolean pinning;
    private boolean extend;

    private String author;
    private String description;

    public TeamEntry(String a, int num, int round, boolean c) {
        author = a;
        teamNum = num;
        this.round = round;
        color = c;
        description = "This person was too lazy to add a description";
        habClimb = -1;
        habStart = -1;
        preload = 0;
        yellow = false;
        descored = false;
        pinning = false;
        extend = false;
    }

    public void setTeamNum(int n) { teamNum = n; }

    public void setRound(int r) { round = r; }

    public void setPoints(int p) { points = p; }

    public void setHabClimb(int hc) { habClimb = hc; }

    public void setHabStart(int hs) { habStart = hs; }

    public void setCargoCnt(int cc) { cargoCnt = cc; }

    public void setHatchCnt(int hc) { hatchCnt = hc; }

    public void setPreload(int pre) { preload = pre; } //0 - neither, 1 - cargo, 2 - hatch

    public void setColor(boolean col) { color = col; }

    public void setCargo(boolean canCargo) { cargo = canCargo; }

    public void setHatch(boolean canHatch) { hatch = canHatch; }

    public void setYellowCard(boolean y) { yellow = y; }

    public void setRedCard(boolean r) { red = r; }

    public void setDescored(boolean d) { descored = d; }

    public void setPinning(boolean pin) { pinning = pin; }

    public void setExtend(boolean ext) { extend = ext; }

    public void setDescription(String d) { description = d.replace("\"",""); }

    public void setAuthor(String a) { author = a; }

    public boolean isCargo() { return cargo; }

    public boolean isColor() { return color; }

    public boolean isHatch() { return hatch; }

    public boolean hasYellow() { return yellow; }

    public boolean hasRed() { return red; }

    public boolean hasDescored() { return descored; }

    public boolean hasPinned() { return pinning; }

    public boolean hasExtended() { return extend; }

    public boolean getColor() { return color; }

    public int getPreload() { return preload; }

    public int getHabClimb() { return habClimb; }

    public int getHabStart() { return habStart; }

    public int getPoints() { return points; }

    public int getRound() { return round; }

    public int getTeamNum() { return teamNum; }

    public int getCargoCnt() { return cargoCnt; }

    public int getHatchCnt() { return hatchCnt; }

    public String getDescription() { return description; }

    public String getAuthor() { return author; }

    public void incrementCargo() { cargoCnt++; }

    public void decrementCargo() { cargoCnt--; }

    public void incrementHatch() { hatchCnt++; }

    public void decrementHatch() { hatchCnt--; }

    public boolean validAuthor() {
        char[] charray = author.toCharArray();
        for(char c : charray) {
            if(!Character.isAlphabetic(c) && c != ' ')
                return false;
        }
        return true;
    }

    public void fillData() {
        hatch = hatchCnt != 0;
        cargo = cargoCnt != 0;
        points += (hatchCnt*2) + (cargoCnt*3);
        if(habStart == 1)
            points+=3;
        if(habStart == 2)
            points+=6;
        if(habClimb == 1)
            points+=3;
        if(habClimb == 2)
            points+=6;
        if(habClimb == 3)
            points+=12;
    }

    @Override
    public String toString() {
        return "Team-"+Integer.toString(teamNum) + "_" + "Round-"+Integer.toString(round);
    }

    @Override
    public boolean equals(Object obj) {
        TeamEntry o = (TeamEntry)obj;
        return o.getTeamNum() == getTeamNum() && o.getRound() == getRound();
    }
}