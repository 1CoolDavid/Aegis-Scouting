package frc.aegis.scoutingapp;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Environment;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.TextView;

import com.google.gson.Gson;
import com.opencsv.CSVWriter;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import static frc.aegis.scoutingapp.MainActivity.entryList;
import static frc.aegis.scoutingapp.MainActivity.teamEntry;

public class ScoringActivity extends Activity implements View.OnClickListener {
    private Button backbtn, submitbtn, hatch_up, hatch_down, cargo_up, cargo_down;
    private RadioButton climb0, climb1, climb2, climb3;
    private TextView hatchCount, cargoCount, teamNum;
    private EditText notes;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_scoring);

        backbtn = findViewById(R.id.back_btn);
        submitbtn = findViewById(R.id.submit_btn);

        hatch_up = findViewById(R.id.incrementHatch);
        hatch_down = findViewById(R.id.decrementHatch);
        cargo_up = findViewById(R.id.incrementCargo);
        cargo_down = findViewById(R.id.decrementCargo);

        climb1 = findViewById(R.id.climb_1);
        climb2 = findViewById(R.id.climb_2);
        climb3 = findViewById(R.id.climb_3);
        climb0 = findViewById(R.id.climb_0);

        hatchCount = findViewById(R.id.hatch_num);
        cargoCount = findViewById(R.id.cargo_num);
        teamNum = findViewById(R.id.team_num_display);

        teamNum.setText(Integer.toString(teamEntry.getTeamNum()));

        notes = findViewById(R.id.description);

        backbtn.setOnClickListener(this);
        submitbtn.setOnClickListener(this);
        hatch_up.setOnClickListener(this);
        hatch_down.setOnClickListener(this);
        cargo_up.setOnClickListener(this);
        cargo_down.setOnClickListener(this);
        climb0.setOnClickListener(this);
        climb1.setOnClickListener(this);
        climb2.setOnClickListener(this);
        climb3.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if(v.getId() == backbtn.getId()) {
            AlertDialog.Builder goBack = new AlertDialog.Builder(this);
            goBack.setTitle("Go Back?");
            goBack.setMessage("Please confirm that you want to be sent to the previous page");
            goBack.setPositiveButton("Confirm", (dialog, which) -> { dialog.dismiss();
                startActivity(new Intent(ScoringActivity.this, MainActivity.class));
            });
            goBack.setNegativeButton("Cancel", (dialog, which) -> {
                dialog.dismiss();
                return;
            });
            AlertDialog alert = goBack.create();
            alert.show();
        } else if(v.getId() == submitbtn.getId()) {
            if(teamEntry.getHabClimb() == -1 || teamEntry.getHabStart() == -1) {
                return;
            }
            AlertDialog.Builder goBack = new AlertDialog.Builder(this);
            goBack.setTitle("Confirm Submission");
            goBack.setMessage("Please confirm that you want to submit your entry");
            goBack.setPositiveButton("Confirm", (dialog, which) -> { dialog.dismiss();
                    teamEntry.setDescription(notes.getText().toString());
                    teamEntry.fillData();
                    uploadFile(teamEntry);
                    if (entryList.isEmpty())
                        initHeaders();
                    entryList.add(teamEntry);
                    saveData();
                    teamEntry = null;
                    startActivity(new Intent(this, MainActivity.class));
            });
            goBack.setNegativeButton("Cancel", (dialog, which) -> {
                dialog.dismiss();
                return;
            });
            AlertDialog alert = goBack.create();
            alert.show();
        } else if(v.getId() == hatch_up.getId()) {
            if(teamEntry.getHatchCnt() < 20) {
                teamEntry.incrementHatch();
                hatchCount.setText(Integer.toString(teamEntry.getHatchCnt()));
            }
        } else if(v.getId() == hatch_down.getId()) {
            if(teamEntry.getHatchCnt() > 0) {
                teamEntry.decrementHatch();
                hatchCount.setText(Integer.toString(teamEntry.getHatchCnt()));
            }
        } else if(v.getId() == cargo_up.getId()) {
            if(teamEntry.getCargoCnt() < 20) {
                teamEntry.incrementCargo();
                cargoCount.setText(Integer.toString(teamEntry.getCargoCnt()));
            }
        } else if(v.getId() == cargo_down.getId()) {
            if(teamEntry.getCargoCnt() > 0) {
                teamEntry.decrementCargo();
                cargoCount.setText(Integer.toString(teamEntry.getCargoCnt()));
            }
        } else if(v.getId() == climb0.getId()) {
            teamEntry.setHabClimb(0);
        } else if(v.getId() == climb1.getId()) {
            teamEntry.setHabClimb(1);
        } else if(v.getId() == climb2.getId()) {
            teamEntry.setHabClimb(2);
        } else if(v.getId() == climb3.getId()) {
            teamEntry.setHabClimb(3);
        }
    }

    /**
     * Updates ArrayList entry in shared preferences
     */
    public void saveData() {
        SharedPreferences preferences = getSharedPreferences("shared preferences", MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        Gson gson = new Gson(); //translator
        String jsonEntries = gson.toJson(entryList); //translates entryList to string
        editor.putString("KEY", jsonEntries);
        editor.apply(); //Overrides previous ArrayList entry
    }

    /**
     * Uploads csv file of entry to Documents folder of the device
     * @param teamEntry the to-be-submitted TeamEntry
     */
    public static void uploadFile(TeamEntry teamEntry) {
        String fileName = teamEntry.toString()+"-AnalysisData.csv";
        String pre = teamEntry.getPreload() == 0 ? "Neither" : teamEntry.getPreload() == 1 ? "Cargo" : "Hatch";
        File file;
        try {
            file = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS).getAbsolutePath() + "/Aegis/");
            file.mkdirs(); //Creates directory if it doesn't exist.

            if (file.getParentFile().mkdirs())
                file.createNewFile();

            File entry = new File(file.getAbsolutePath(), fileName);
            FileWriter outputfile = new FileWriter(entry);

            // create CSVWriter object filewriter object as parameter
            CSVWriter writer = new CSVWriter(outputfile, ',', CSVWriter.NO_QUOTE_CHARACTER, CSVWriter.DEFAULT_ESCAPE_CHARACTER, CSVWriter.DEFAULT_LINE_END);

            // add data to csv
            String[] data1 = { teamEntry.getAuthor(), Integer.toString(teamEntry.getTeamNum()), Integer.toString(teamEntry.getRound()), Integer.toString(teamEntry.getPoints()), pre, Integer.toString(teamEntry.getHatchCnt()), Integer.toString(teamEntry.getCargoCnt()), Integer.toString(teamEntry.getHabStart()), Integer.toString(teamEntry.getHabClimb()), teamEntry.getDescription() };
            writer.writeNext(data1);

            // closing writer connection
            writer.flush();
            writer.close();
        }
        catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Initializes the headers.csv file for easy computation (Exportation purposes)
     */
    public static void initHeaders() {
        String fileName = "Headers.csv";
        File file;
        try {
            file = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS).getAbsolutePath() + "/Aegis/");
            file.mkdirs();

            if (file.getParentFile().mkdirs())
                file.createNewFile();
            // create FileWriter object with file as parameter
            File entry = new File(file.getAbsolutePath(), fileName);
            FileWriter outputfile = new FileWriter(entry);

            // create CSVWriter object filewriter object as parameter
            CSVWriter writer = new CSVWriter(outputfile, ',', CSVWriter.NO_QUOTE_CHARACTER, CSVWriter.DEFAULT_ESCAPE_CHARACTER, CSVWriter.DEFAULT_LINE_END);

            // adding header to csv
            String[] header = { "Author", "Number", "Round", "Points Scored", "Preload", "Hatches", "Cargo", "Hab Start", "Hab Climb", "Description" };
            writer.writeNext(header);

            // closing writer connection
            writer.flush();
            writer.close();
        }
        catch (IOException e) {
            e.printStackTrace();
        }
    }
}