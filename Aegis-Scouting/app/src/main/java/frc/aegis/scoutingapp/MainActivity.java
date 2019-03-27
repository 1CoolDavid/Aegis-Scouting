package frc.aegis.scoutingapp;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RadioButton;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

public class MainActivity extends Activity implements View.OnClickListener {
    private Button beginbtn, localbtn;
    private EditText numEntry, roundEntry, authorEntry;
    private RadioButton redOpt, blueOpt, hab1, hab2;
    private ImageButton preloadbtn;
    public static TeamEntry teamEntry; //Current Entry
    public static ArrayList<TeamEntry> entryList; //Data
    private boolean color, errors, midMatch;
    private int preloadStatus, habStart;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        beginbtn = (Button)findViewById(R.id.start_btn);
        localbtn = (Button)findViewById(R.id.local_btn);

        numEntry = (EditText)findViewById(R.id.team_num_entry);
        roundEntry = (EditText)findViewById(R.id.round_entry);
        authorEntry = (EditText)findViewById(R.id.author_entry);

        redOpt = (RadioButton)findViewById(R.id.redTeam);
        blueOpt = (RadioButton)findViewById(R.id.blueTeam);
        hab1 = (RadioButton)findViewById(R.id.hab_1);
        hab2 = (RadioButton)findViewById(R.id.hab_2);

        preloadbtn = (ImageButton)findViewById(R.id.preload_selection);

        beginbtn.setOnClickListener(this);
        localbtn.setOnClickListener(this);
        redOpt.setOnClickListener(this);
        blueOpt.setOnClickListener(this);
        hab1.setOnClickListener(this);
        hab2.setOnClickListener(this);
        preloadbtn.setOnClickListener(this);

        preloadStatus = 0;
        habStart = 1;

        //Inputting previous entries
        if(teamEntry != null) {
            numEntry.setText(Integer.toString(teamEntry.getTeamNum()));
            authorEntry.setText(teamEntry.getAuthor());
            roundEntry.setText(Integer.toString(teamEntry.getRound()));
            preloadStatus = teamEntry.getPreload();
            habStart = teamEntry.getHabStart();

            if(teamEntry.getColor())
                blueOpt.toggle();
            else
                redOpt.toggle();

            switch (preloadStatus) {
                case 0:
                    preloadbtn.setBackgroundResource(R.mipmap.ic_neither);
                    break;
                case 1:
                    preloadbtn.setBackgroundResource(R.mipmap.ic_cargo);
                    break;
                case 2:
                    preloadbtn.setBackgroundResource(R.mipmap.ic_hatch);
                    break;
            }

            switch (habStart) {
                case 1:
                    hab1.toggle();
                case 2:
                    hab2.toggle();
            }
        }
        midMatch = teamEntry != null && (teamEntry.getHatchCnt() != 0 || teamEntry.getCargoCnt() != 0 || teamEntry.getHabClimb() != -1 || !teamEntry.hasDescored() || !teamEntry.hasPinned() || !teamEntry.hasYellow() || !teamEntry.hasRed());

        loadData();
    }

    @Override
    public void onClick(View v) {

        if(v.getId() == R.id.start_btn) {
            //Checks for empty fields by catching NullPointerExceptions
            try {
                if(midMatch) {
                    teamEntry.setAuthor(authorEntry.getText().toString());
                    teamEntry.setTeamNum(Integer.parseInt(numEntry.getText().toString()));
                    teamEntry.setRound(Integer.parseInt(roundEntry.getText().toString()));
                    teamEntry.setColor(color);
                }
                else
                    teamEntry = new TeamEntry(authorEntry.getText().toString(), Integer.parseInt(numEntry.getText().toString()), Integer.parseInt(roundEntry.getText().toString()), color);
            } catch (Exception e) {
                Toast.makeText(MainActivity.this, "Please fill all fields", Toast.LENGTH_SHORT).show();
                return;
            }

            teamEntry.setPreload(preloadStatus);
            teamEntry.setHabStart(habStart);

            //Checks for trolls
            errors = !teamEntry.validAuthor() || teamEntry.getAuthor().length() >= 25 || teamEntry.getAuthor().length() <= 0 || teamEntry.getTeamNum() >= 10000 || teamEntry.getTeamNum() <= 0 || teamEntry.getRound() < 0 || (!redOpt.isChecked() && !blueOpt.isChecked()) || (!hab1.isChecked() && !hab2.isChecked());

            if (errors) {
                AlertDialog.Builder builder = new AlertDialog.Builder(this);
                builder.setTitle("Errors Detected");
                builder.setMessage("Please input a valid team number (positive values, etc). The author name should have no special characters and be no longer than 25 characters. A color and hab level must be selected."); //message to display
                builder.setPositiveButton("OK", (dialog, which) -> dialog.dismiss());
                AlertDialog alert = builder.create();
                alert.show();
            } else {
                if(teamEntry.getTeamNum() == 5243) {
                    AlertDialog.Builder is5243 = new AlertDialog.Builder(this);
                    is5243.setTitle("Are You Scouting 5243?");
                    is5243.setMessage("Please confirm that you are scouting 5243 and are not just saying you are from 5243");
                    is5243.setPositiveButton("I'm Scouting 5243", (dialog, which) -> { dialog.dismiss();
                        startActivity(new Intent(MainActivity.this, ScoringActivity.class));
                    });
                    is5243.setNegativeButton("Cancel", (dialog, which) -> {
                        dialog.dismiss();
                        return;
                    });

                    AlertDialog alert = is5243.create();
                    alert.show();
                } else {
                    if (matchingEntry(teamEntry)) {
                        AlertDialog.Builder match = new AlertDialog.Builder(this);
                        match.setTitle("Matching Entry Already Detected");
                        match.setMessage("Team " + Integer.toString(teamEntry.getTeamNum()) + " at round " + Integer.toString(teamEntry.getRound()) + " has already been entered before. Please confirm that this is intentional");
                        match.setNegativeButton("Cancel", ((dialog, which) -> {
                            dialog.dismiss();
                            return;
                        }));
                        match.setPositiveButton("Continue", ((dialog, which) -> startActivity(new Intent(this, ScoringActivity.class))));

                        AlertDialog alert = match.create();
                        alert.show();
                    } else {
                        startActivity(new Intent(this, ScoringActivity.class));
                    }
                }
            }
        }
        if(v.getId() == R.id.local_btn)
            startActivity(new Intent(this, LocalDataActivity.class));
        if(v.getId() == R.id.redTeam)
            color=false;
        if(v.getId() == R.id.blueTeam)
            color=true;
        if(v.getId() == R.id.preload_selection) {
            if(preloadStatus == 0) {
                preloadbtn.setBackgroundResource(R.mipmap.ic_cargo);
                preloadStatus++;
            }
            else if(preloadStatus == 1) {
                preloadbtn.setBackgroundResource(R.mipmap.ic_hatch);
                preloadStatus++;
            }
            else { //2
                preloadbtn.setBackgroundResource(R.mipmap.ic_neither);
                preloadStatus = 0;
            }
        }
        if(v.getId() == R.id.hab_1) {
            habStart=1;
        }
        if(v.getId() == R.id.hab_2) {
            habStart=2;
        }
    }

    /**
     * Grabs data from shared preferences and initializes the ArrayList. If shared preferences contains no data, a new ArrayList is made.
     */
    public void loadData() {
        SharedPreferences preferences = getSharedPreferences("shared preferences", MODE_PRIVATE); //App data
        Gson gson = new Gson(); //Translator
        String jsonEntries = preferences.getString("KEY", null); //Grabs data entry for ArrayList
        Type type = new TypeToken<ArrayList<TeamEntry>>() {}.getType();
        entryList = gson.fromJson(jsonEntries, type); //Translates data entry to ArrayList -> entryList

        if(entryList == null) {
            entryList = new ArrayList<>();
        }
    }

    /**
     * Checks if ArrayList of TeamEntries has an element with the same team number and round
     * @param t is the TeamEntry currently being created
     * @return true is match exists, false otherwise.
     */
    public boolean matchingEntry(TeamEntry t) {
        for(TeamEntry entry : entryList) {
            if (t.equals(entry))
                return true;
        }
        return false;
    }
}
