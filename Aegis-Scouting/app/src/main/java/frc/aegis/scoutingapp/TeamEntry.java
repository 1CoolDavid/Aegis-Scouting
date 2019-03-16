package frc.aegis.scoutingapp;

import android.os.Build;

import java.util.stream.Collectors;

public class TeamEntry {

    private int teamNum;
    private int round;
    private int points;
    private int habClimb;
    private int habStart;
    private int maxCargoLvl;
    private int maxHatchLvl;

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
    }

    public TeamEntry(String a) {
        author = a;
        teamNum = -1;
        round = -1;
        points = -1;
        habClimb = -1;
        habStart = -1;
        maxHatchLvl = -1;
        maxCargoLvl = -1;
        description = "This person was too lazy to add a description";
    }

    public void setTeamNum(int n) { teamNum = n; }

    public void setRound(int r) { round = r; }

    public void setPoints(int p) { points = p; }

    public void setHabClimb(int hc) { habClimb = hc; }

    public void setHabStart(int hs) { habStart = hs; }

    public void setMaxCargoLvl(int cl) { maxCargoLvl = cl; }

    public void setMaxHatchLvl(int hl) { maxHatchLvl = hl; }

    public void setColor(boolean col) { color = col; }

    public void setCargo(boolean canCargo) { cargo = canCargo; }

    public void setHatch(boolean canHatch) { hatch = canHatch; }

    public void setDescription(String d) { description = d; }

    public void setAuthor(String a) { author = a; }

    public boolean isCargo() { return cargo; }

    public boolean isColor() { return color; }

    public boolean isHatch() { return hatch; }

    public int getHabClimb() { return habClimb; }

    public int getHabStart() { return habStart; }

    public int getMaxCargoLvl() { return maxCargoLvl; }

    public int getMaxHatchLvl() { return maxHatchLvl; }

    public int getPoints() { return points; }

    public int getRound() { return round; }

    public int getTeamNum() { return teamNum; }

    public String getDescription() { return description; }

    public String getAuthor() { return author; }

    public boolean suspiciousAuthor() {
        return author.contains("1") || author.contains("2") || author.contains("3") || author.contains("4") || author.contains("5") || author.contains("6") || author.contains("7") || author.contains("8") || author.contains("9") || author.contains("0");
    }

    public boolean suspiciousScore() { return points >= 35; }

    public boolean suspiciousAbilities() {
        if(!hatch && !cargo)
            return true;
        if(!hatch && maxHatchLvl >= 0)
            return true;
        if(!cargo && maxCargoLvl >= 0)
            return true;
        return false;
    }

    public boolean suspiciousRound() { return round >= 80; }
}
