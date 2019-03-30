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

    TeamEntry(String a, int num, int round, boolean c) {
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

    void setYellowCard(boolean y) {
        yellow = y;
    }

    void setRedCard(boolean r) {
        red = r;
    }
    public void setPoints(int p) { points = p; }

    void setDescored(boolean d) {
        descored = d;
    }

    void setPinning(boolean pin) {
        pinning = pin;
    }
    public void setCargoCnt(int cc) { cargoCnt = cc; }
    public void setHatchCnt(int hc) { hatchCnt = hc; }

    void setExtend(boolean ext) {
        extend = ext;
    }
    public void setColor(boolean col) { color = col; }
    public void setCargo(boolean canCargo) { cargo = canCargo; }
    public void setHatch(boolean canHatch) { hatch = canHatch; }

    //public boolean isCargo() { return cargo; }
    //public boolean isColor() { return color; }
    //public boolean isHatch() { return hatch; }
    boolean hasYellow() {
        return yellow;
    }

    boolean hasRed() {
        return red;
    }

    boolean hasDescored() {
        return descored;
    }

    boolean hasPinned() {
        return pinning;
    }

    boolean hasExtended() {
        return extend;
    }

    int getPreload() {
        return preload;
    }

    void setPreload(int pre) {
        preload = pre;
    } //0 - neither, 1 - cargo, 2 - hatch

    int getHabClimb() {
        return habClimb;
    }

    void setHabClimb(int hc) {
        habClimb = hc;
    }

    int getHabStart() {
        return habStart;
    }

    void setHabStart(int hs) {
        habStart = hs;
    }

    int getPoints() {
        return points;
    }
    public boolean getColor() { return color; }

    int getRound() {
        return round;
    }

    void setRound(int r) {
        round = r;
    }

    int getTeamNum() {
        return teamNum;
    }

    void setTeamNum(int n) {
        teamNum = n;
    }

    int getCargoCnt() {
        return cargoCnt;
    }

    int getHatchCnt() {
        return hatchCnt;
    }

    String getDescription() {
        return description;
    }

    void setDescription(String d) {
        description = d.replace("\"", "");
    }

    String getAuthor() {
        return author;
    }

    void setAuthor(String a) {
        author = a;
    }

    void incrementCargo() {
        cargoCnt++;
    }

    void decrementCargo() {
        cargoCnt--;
    }

    void incrementHatch() {
        hatchCnt++;
    }

    void decrementHatch() {
        hatchCnt--;
    }

    boolean validAuthor() {
        char[] charray = author.toCharArray();
        for(char c : charray) {
            if(!Character.isAlphabetic(c) && c != ' ')
                return false;
        }
        return true;
    }

    void fillData() {
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