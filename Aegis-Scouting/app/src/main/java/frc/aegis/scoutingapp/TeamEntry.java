package frc.aegis.scoutingapp;

import android.os.Build;
import android.os.Environment;
import android.provider.ContactsContract;

import com.opencsv.CSVWriter;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
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

    public void toFile() {

        String fileName = toString()+"-AnalysisData.csv";
        File file;
        File root = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)+"/Aegis/", fileName);
        if (!root.exists()) {
            root.mkdirs();
        }
        file = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)+"/Aegis/", fileName);

        try {
            // create FileWriter object with file as parameter
            FileWriter outputfile = new FileWriter(file);

            // create CSVWriter object filewriter object as parameter
            CSVWriter writer = new CSVWriter(outputfile, ',', CSVWriter.NO_QUOTE_CHARACTER, CSVWriter.DEFAULT_ESCAPE_CHARACTER, CSVWriter.DEFAULT_LINE_END);

            // adding header to csv
            String[] header = { "Number", "Round", "Points Scored", "# Hatches", "# Cargo", "Hab Start", "Hab Climb", "Description" };
            writer.writeNext(header);

            // add data to csv
            String[] data1 = { Integer.toString(teamNum), Integer.toString(round), Integer.toString(points), Integer.toString(hatchCnt), Integer.toString(cargoCnt), Integer.toString(habStart), Integer.toString(habClimb) };
            writer.writeNext(data1);
            String[] data2 = { "Description: ", description };
            writer.writeNext(data2);

            // closing writer connection
            writer.close();
        }
        catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
}