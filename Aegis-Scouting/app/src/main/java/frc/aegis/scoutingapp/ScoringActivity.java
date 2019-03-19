package frc.aegis.scoutingapp;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Environment;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RadioButton;
import android.widget.TextView;
import android.widget.Toast;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import static android.content.ContentValues.TAG;
import static frc.aegis.scoutingapp.MainActivity.entryList;
import static frc.aegis.scoutingapp.MainActivity.teamEntry;

public class ScoringActivity extends Activity implements View.OnClickListener {

    Button backbtn, submitbtn, hatch_up, hatch_down, cargo_up, cargo_down;
    RadioButton hab1, hab2, climb0, climb1, climb2, climb3;
    TextView hatchCount, cargoCount;
    EditText notes;
    SharedPreferences pref;
    SharedPreferences.Editor editor;
    final String UPLOAD_KEY = "Aegis";

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

        pref = getSharedPreferences(TAG, Context.MODE_PRIVATE);
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
            AlertDialog.Builder goBack = new AlertDialog.Builder(this);
            goBack.setTitle("Confirm Submission");
            goBack.setMessage("Please confirm that you want to submit your entry");
            goBack.setPositiveButton("Confirm", (dialog, which) -> { dialog.dismiss();
                if(teamEntry != null) {
                    teamEntry.fillData();
                    teamEntry.toFile();
                    entryList.add(teamEntry);
                    teamEntry = null;


                }
                else {
                    Toast.makeText(this, "Data already uploaded", Toast.LENGTH_SHORT).show();
                }
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
}
