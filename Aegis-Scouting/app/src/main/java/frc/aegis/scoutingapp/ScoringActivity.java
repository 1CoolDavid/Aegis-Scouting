package frc.aegis.scoutingapp;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
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
    private TextView hatchCount, cargoCount, teamInfo;
    private CheckBox pin, descore, extend, yellow, red;
    private EditText notes;
    public static final String DEVICE_NAME = Build.MANUFACTURER;
    public static final String DEVICE_MODEL = Build.FINGERPRINT;

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
        teamInfo = findViewById(R.id.team_info_display);

        pin = findViewById(R.id.pinning_chk);
        descore = findViewById(R.id.descore_chk);
        extend = findViewById(R.id.extension_chk);
        yellow = findViewById(R.id.yellow_chk);
        red = findViewById(R.id.red_chk);

        notes = findViewById(R.id.description);

        autoFill();

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
        pin.setOnClickListener(this);
        descore.setOnClickListener(this);
        extend.setOnClickListener(this);
        yellow.setOnClickListener(this);
        red.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if(v.getId() == backbtn.getId()) {
            AlertDialog.Builder goBack = new AlertDialog.Builder(this);
            goBack.setTitle("Go Back?");
            goBack.setMessage("Please confirm that you want to be sent to the previous page");
            goBack.setPositiveButton("Confirm", (dialog, which) -> { dialog.dismiss();
                if(!notes.getText().toString().equals("")) {
                    teamEntry.setDescription(notes.getText().toString());
                }
                startActivity(new Intent(ScoringActivity.this, MainActivity.class));
            });
            goBack.setNegativeButton("Cancel", (dialog, which) -> {
                dialog.dismiss();
               // return;
            });
            AlertDialog alert = goBack.create();
            alert.show();
        } else if(v.getId() == submitbtn.getId()) {
            if(teamEntry.getHabClimb() == -1) {
                return;
            }
            AlertDialog.Builder goBack = new AlertDialog.Builder(this);
            goBack.setTitle("Confirm Submission");
            goBack.setMessage("Please confirm that you want to submit your entry");
            goBack.setPositiveButton("Confirm", (dialog, which) -> { dialog.dismiss();
                    teamEntry.setDescription(notes.getText().toString());
                    teamEntry.fillData();
                    if (noLocalData())
                        initHeaders();
                    uploadFile(teamEntry);
                    entryList.add(teamEntry);
                    saveData();
                    teamEntry = null;
                    startActivity(new Intent(this, MainActivity.class));
            });
            goBack.setNegativeButton("Cancel", (dialog, which) -> {
                dialog.dismiss();
                //return;
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
        } else if(v.getId() == pin.getId()) {
            teamEntry.setPinning(!teamEntry.hasPinned());
        } else if(v.getId() == descore.getId()) {
            teamEntry.setDescored(!teamEntry.hasDescored());
        } else if(v.getId() == extend.getId()) {
            teamEntry.setExtend(!teamEntry.hasExtended());
        } else if(v.getId() == yellow.getId()) {
            teamEntry.setYellowCard(!teamEntry.hasYellow());
        } else if(v.getId() == red.getId()) {
            teamEntry.setRedCard(!teamEntry.hasRed());
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
        String fileName = ("AnalysisData" + DEVICE_NAME + DEVICE_MODEL + ".csv");
        String pre = teamEntry.getPreload() == 0 ? "Neither" : teamEntry.getPreload() == 1 ? "Cargo" : "Hatch";
        String color = teamEntry.getColor() ? "Blue" : "Red";
        File file;
        try {
            file = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS).getAbsolutePath() + "/Aegis/");

            File entry = new File(file.getAbsolutePath(), fileName);
            FileWriter outputfile = new FileWriter(entry, true);

            // create CSVWriter object filewriter object as parameter
            CSVWriter writer = new CSVWriter(outputfile, ',', CSVWriter.NO_QUOTE_CHARACTER, CSVWriter.DEFAULT_ESCAPE_CHARACTER, CSVWriter.DEFAULT_LINE_END);

            // add data to csv
            String[] data = { teamEntry.getAuthor(), Integer.toString(teamEntry.getTeamNum()), Integer.toString(teamEntry.getRound()), color, Integer.toString(teamEntry.getPoints()), pre, Integer.toString(teamEntry.getHatchCnt()), Integer.toString(teamEntry.getCargoCnt()), Integer.toString(teamEntry.getHabStart()), Integer.toString(teamEntry.getHabClimb()), Boolean.toString(teamEntry.hasPinned()), Boolean.toString(teamEntry.hasDescored()), Boolean.toString(teamEntry.hasExtended()), Boolean.toString(teamEntry.hasYellow()), Boolean.toString(teamEntry.hasRed()), teamEntry.getDescription() };
            writer.writeNext(data);

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
        String fileName = ("AnalysisData" + DEVICE_NAME + DEVICE_MODEL + ".csv");
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
            String[] header = { "Author", "Number", "Round", "Color", "Points Scored", "Preload", "Hatches", "Cargo", "Hab Start", "Hab Climb", "Pinning", "Descoring", "Extends", "Yellow Card", "Red Card" ,"Description" };
            writer.writeNext(header);

            // closing writer connection
            writer.flush();
            writer.close();
        }
        catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static boolean noLocalData() {
        String fileName = "AnalysisData.csv";
        File file = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS).getAbsolutePath() + "/Aegis/");
        return new File(file.getAbsolutePath(), fileName).exists();
    }

    public void autoFill() {
        teamInfo.setText("Team: " + teamEntry.getTeamNum());
        hatchCount.setText(Integer.toString(teamEntry.getHatchCnt()));
        cargoCount.setText(Integer.toString(teamEntry.getCargoCnt()));

        if(teamEntry.getHabClimb() == 0)
            climb0.toggle();
        else if(teamEntry.getHabClimb() == 1)
            climb1.toggle();
        else if(teamEntry.getHabClimb() == 2)
            climb2.toggle();
        else if(teamEntry.getHabClimb() == 3)
            climb3.toggle();

        red.setChecked(teamEntry.hasRed());
        yellow.setChecked(teamEntry.hasYellow());
        pin.setChecked(teamEntry.hasPinned());
        descore.setChecked(teamEntry.hasDescored());
        extend.setChecked(teamEntry.hasExtended());

        if(!teamEntry.getDescription().equals("This person was too lazy to add a description")) {
            notes.setText(teamEntry.getDescription());
        }
    }
}