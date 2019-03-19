package frc.aegis.scoutingapp;

import android.os.Build;

import java.util.stream.Collectors;

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
    }

    public void setTeamNum(int n) { teamNum = n; }

    public void setRound(int r) { round = r; }

    public void setPoints(int p) { points = p; }

    public void setHabClimb(int hc) { habClimb = hc; }

    public void setHabStart(int hs) { habStart = hs; }

    public void setCargoCnt(int cc) { cargoCnt = cc; }

    public void setHatchCnt(int hc) { hatchCnt = hc; }

    public void setColor(boolean col) { color = col; }

    public void setCargo(boolean canCargo) { cargo = canCargo; }

    public void setHatch(boolean canHatch) { hatch = canHatch; }

    public void setDescription(String d) { description = d; }

    public void setAuthor(String a) { author = a; }

    public void setPreload(int pre) { preload = pre; }

    public boolean isCargo() { return cargo; }

    public boolean isColor() { return color; }

    public boolean isHatch() { return hatch; }

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

    public boolean suspiciousAbilities() {
        if(!hatch && !cargo)
            return true;
        return false;
    }
}