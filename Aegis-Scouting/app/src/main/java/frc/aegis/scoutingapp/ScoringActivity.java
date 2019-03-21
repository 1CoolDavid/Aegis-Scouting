package frc.aegis.scoutingapp;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Environment;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.opencsv.CSVWriter;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.lang.reflect.Type;
import java.util.ArrayList;

import static frc.aegis.scoutingapp.MainActivity.teamEntry;

public class ScoringActivity extends Activity implements View.OnClickListener {
    private Button backbtn, submitbtn, hatch_up, hatch_down, cargo_up, cargo_down;
    private RadioButton hab1, hab2, climb0, climb1, climb2, climb3;
    private ArrayList<TeamEntry> entryList;
    private TextView hatchCount, cargoCount;
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

        hab1 = findViewById(R.id.hab_1);
        hab2 = findViewById(R.id.hab_2);

        climb1 = findViewById(R.id.climb_1);
        climb2 = findViewById(R.id.climb_2);
        climb3 = findViewById(R.id.climb_3);
        climb0 = findViewById(R.id.climb_0);

        hatchCount = findViewById(R.id.hatch_num);
        cargoCount = findViewById(R.id.cargo_num);

        notes = findViewById(R.id.description);

        backbtn.setOnClickListener(this);
        submitbtn.setOnClickListener(this);
        hatch_up.setOnClickListener(this);
        hatch_down.setOnClickListener(this);
        cargo_up.setOnClickListener(this);
        cargo_down.setOnClickListener(this);
        hab1.setOnClickListener(this);
        hab2.setOnClickListener(this);
        climb0.setOnClickListener(this);
        climb1.setOnClickListener(this);
        climb2.setOnClickListener(this);
        climb3.setOnClickListener(this);

        loadData();
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
                    teamEntry.fillData();
                    uploadFile(teamEntry);
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
        } else if(v.getId() == hab1.getId()) {
            teamEntry.setHabStart(1);
        } else if(v.getId() == hab2.getId()) {
            teamEntry.setHabStart(2);
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

    public void saveData() {
        SharedPreferences preferences = getSharedPreferences("shared preferences", MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        Gson gson = new Gson();
        String jsonEntries = gson.toJson(entryList);
        editor.putString("KEY", jsonEntries);
        editor.apply();
    }

    public void loadData() {
        SharedPreferences preferences = getSharedPreferences("shared preferences", MODE_PRIVATE);
        Gson gson = new Gson();
        String jsonEntries = preferences.getString("KEY", null);
        Type type = new TypeToken<ArrayList<TeamEntry>>() {}.getType();
        entryList = gson.fromJson(jsonEntries, type);

        if(entryList == null) {
            entryList = new ArrayList<>();
        }
    }

    public static void uploadFile(TeamEntry teamEntry) {

        String fileName = teamEntry.toString()+"-AnalysisData.csv";
        //File myDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS);
        File file;
        try {
            //System.out.println(myDir.getAbsolutePath());
            //myDir.mkdirs();

            file = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS).getAbsolutePath() + "/Aegis/");
            file.mkdirs();

            if (file.getParentFile().mkdirs())
                file.createNewFile();
            System.out.println(file.getAbsolutePath());
            // create FileWriter object with file as parameter
            File entry = new File(file.getAbsolutePath(), fileName);
            FileWriter outputfile = new FileWriter(entry);

            // create CSVWriter object filewriter object as parameter
            CSVWriter writer = new CSVWriter(outputfile, ',', CSVWriter.NO_QUOTE_CHARACTER, CSVWriter.DEFAULT_ESCAPE_CHARACTER, CSVWriter.DEFAULT_LINE_END);

            // adding header to csv
            String[] header = { "Number", "Round", "Points Scored", "# Hatches", "# Cargo", "Hab Start", "Hab Climb", "Description" };
            writer.writeNext(header);

            // add data to csv
            String[] data1 = { Integer.toString(teamEntry.getTeamNum()), Integer.toString(teamEntry.getRound()), Integer.toString(teamEntry.getPoints()), Integer.toString(teamEntry.getHatchCnt()), Integer.toString(teamEntry.getCargoCnt()), Integer.toString(teamEntry.getHabStart()), Integer.toString(teamEntry.getHabClimb()) };
            writer.writeNext(data1);
            String[] data2 = { "Description: ", teamEntry.getDescription() };
            writer.writeNext(data2);

            // closing writer connection
            writer.flush();
            writer.close();
        }
        catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
}
