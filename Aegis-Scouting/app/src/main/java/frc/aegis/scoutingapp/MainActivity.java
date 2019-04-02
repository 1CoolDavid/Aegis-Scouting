package frc.aegis.scoutingapp;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;

import io.sentry.Sentry;
import io.sentry.android.AndroidSentryClientFactory;


public class MainActivity<ctx> extends Activity implements View.OnClickListener {
    private Button beginbtn, localbtn;
    private EditText numEntry, roundEntry, authorEntry;
    private RadioButton hab1, hab2, red1, red2, red3, blue1, blue2, blue3;
    private ImageButton preloadbtn, gearbtn;
    private LinearLayout main, location;
    private TextView locationTxt;
    public static TeamEntry teamEntry; //Current Entry
    public static ArrayList<TeamEntry> entryList; //Data
    private boolean errors, midMatch;
    private int preloadStatus, habStart;
    public static String deviceId;

    @SuppressLint("SetTextI18n")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        beginbtn = findViewById(R.id.start_btn);
        localbtn = findViewById(R.id.local_btn);

        numEntry = findViewById(R.id.team_num_entry);
        roundEntry = findViewById(R.id.round_entry);
        authorEntry = findViewById(R.id.author_entry);

        hab1 = findViewById(R.id.hab_1);
        hab2 = findViewById(R.id.hab_2);
        red1 = findViewById(R.id.red_1);
        red2 = findViewById(R.id.red_2);
        red3 = findViewById(R.id.red_3);
        blue1 = findViewById(R.id.blue_1);
        blue2 = findViewById(R.id.blue_2);
        blue3 = findViewById(R.id.blue_3);

        preloadbtn = findViewById(R.id.preload_selection);
        gearbtn = findViewById(R.id.gear_btn);

        main = findViewById(R.id.mainLayout);
        location = findViewById(R.id.id_bar);

        locationTxt = findViewById(R.id.location_txt);

        beginbtn.setOnClickListener(this);
        localbtn.setOnClickListener(this);
        red1.setOnClickListener(this::IdClicker);
        red2.setOnClickListener(this::IdClicker);
        red3.setOnClickListener(this::IdClicker);
        blue1.setOnClickListener(this::IdClicker);
        blue2.setOnClickListener(this::IdClicker);
        blue3.setOnClickListener(this::IdClicker);
        hab1.setOnClickListener(this);
        hab2.setOnClickListener(this);
        preloadbtn.setOnClickListener(this);
        gearbtn.setOnClickListener(this);
        main.setOnClickListener(this);

        loadLocation();

        displayLocation();

        preloadStatus = 0;
        habStart = 1;

        //Inputting previous entries
        if(teamEntry != null) {
            numEntry.setText(Integer.toString(teamEntry.getTeamNum()));
            authorEntry.setText(teamEntry.getAuthor());
            roundEntry.setText(Integer.toString(teamEntry.getRound()));
            preloadStatus = teamEntry.getPreload();
            habStart = teamEntry.getHabStart();

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

        if(v.getId() != R.id.gear_btn) {
            RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams)main.getLayoutParams();
            params.removeRule(RelativeLayout.ALIGN_PARENT_LEFT);
            location.setVisibility(View.GONE);
        }
        if(v.getId() == R.id.start_btn) {
            try {
                if(midMatch) {
                    teamEntry.setAuthor(authorEntry.getText().toString());
                    teamEntry.setTeamNum(Integer.parseInt(numEntry.getText().toString()));
                    teamEntry.setRound(Integer.parseInt(roundEntry.getText().toString()));
                    teamEntry.setColor(deviceId.contains("Blue"));
                }
                else
                    teamEntry = new TeamEntry(authorEntry.getText().toString(), Integer.parseInt(numEntry.getText().toString()), Integer.parseInt(roundEntry.getText().toString()), deviceId.contains("Blue"));
            } catch (Exception e) {
                Toast.makeText(MainActivity.this, "Please fill all fields", Toast.LENGTH_SHORT).show();
                Sentry.capture("User did not fill all fields");
                return;
            }

            teamEntry.setPreload(preloadStatus);
            teamEntry.setHabStart(habStart);

            //Checks for trolls
            errors = !teamEntry.validAuthor() || teamEntry.getAuthor().length() >= 25 || teamEntry.getAuthor().length() <= 0 || teamEntry.getTeamNum() >= 10000 || teamEntry.getTeamNum() <= 0 || teamEntry.getRound() < 0 || deviceId == null || (!hab1.isChecked() && !hab2.isChecked());

            if (errors) {
                AlertDialog.Builder builder = new AlertDialog.Builder(this);
                builder.setTitle("Errors Detected");
                Sentry.capture("user Error on team input page. Invalid Character");
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
                        saveLocation();
                        startActivity(new Intent(MainActivity.this, ScoringActivity.class));
                    });
                    is5243.setNegativeButton("Cancel", (dialog, which) -> {
                        dialog.dismiss();
                        //return;
                    });

                    AlertDialog alert = is5243.create();
                    alert.show();
                } else {
                    if (matchingEntry(teamEntry)) {
                        AlertDialog.Builder match = new AlertDialog.Builder(this);
                        match.setTitle("Matching Entry Already Detected");
                        match.setMessage("Team " + Integer.toString(teamEntry.getTeamNum()) + " at round " + Integer.toString(teamEntry.getRound()) + " has already been entered before. Please confirm that this is intentional");
                        match.setNegativeButton("Cancel", ((dialog, which) -> {
                            Sentry.capture("User attempted to enter a team that was already scouted");
                            dialog.dismiss();
                            // return;
                        }));
                        match.setPositiveButton("Continue", ((dialog, which) -> {
                            saveLocation();
                            startActivity(new Intent(this, ScoringActivity.class));
                        }));

                        AlertDialog alert = match.create();
                        alert.show();
                    } else {
                        saveLocation();
                        startActivity(new Intent(this, ScoringActivity.class));
                    }
                }
            }
        }
        if(v.getId() == R.id.local_btn)
            startActivity(new Intent(this, LocalDataActivity.class));
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
        if(v.getId() == R.id.gear_btn) {
            if ((entryList != null && !entryList.isEmpty())) {
                AlertDialog.Builder alertDialog = new AlertDialog.Builder(this);
                alertDialog.setTitle("Location Already Entered");
                alertDialog.setPositiveButton("OK", ((dialog, which) -> {
                    Sentry.capture("User atttempted to select new location when one was entered");
                    dialog.dismiss();
                    // return;
                }));
                alertDialog.setMessage("Data has already been entered under the current location. To change the set location, clear the local cache on the app");
                AlertDialog alert = alertDialog.create();
                alert.show();
            } else {
                RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams) main.getLayoutParams();
                params.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
                location.setVisibility(View.VISIBLE);
                if(deviceId == null)
                    return;
                switch (deviceId) {
                    case "RedOne":
                        red1.toggle();
                        break;
                    case "RedTwo":
                        red2.toggle();
                        break;
                    case "RedThree":
                        red3.toggle();
                        break;
                    case "BlueOne":
                        blue1.toggle();
                        break;
                    case "BlueTwo":
                        blue2.toggle();
                        break;
                    case "BlueThree":
                        blue3.toggle();
                        break;
                }
            }
        }
        Context ctx = this.getApplicationContext();

        // Use the Sentry DSN (client key) from the Project Settings page on Sentry -- RTS
        String sentryDsn = "https://c11ad45a67d24c93a77aaf9890fdf0b1@sentry.io/1428669";
        Sentry.init(sentryDsn, new AndroidSentryClientFactory(ctx));
    }


    public void IdClicker(View v) {
        switch (v.getId()) {
            case R.id.red_1:
                deviceId = "RedOne";
                break;
            case R.id.red_2:
                deviceId = "RedTwo";
                break;
            case R.id.red_3:
                deviceId = "RedThree";
                break;
            case R.id.blue_1:
                deviceId = "BlueOne";
                break;
            case R.id.blue_2:
                deviceId = "BlueTwo";
                break;
            case R.id.blue_3:
                deviceId = "BlueThree";
                break;
        }
        displayLocation();
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

    public void saveLocation() {
        SharedPreferences pref = getSharedPreferences("location preferences", MODE_PRIVATE);
        SharedPreferences.Editor editor = pref.edit();
        editor.putString("LOC", deviceId);
        editor.apply(); //change to apply to run in background
    }

    public void loadLocation() {
        SharedPreferences pref = getSharedPreferences("location preferences", MODE_PRIVATE);
        deviceId = pref.getString("LOC", null);
    }

    public void displayLocation() {
        if(deviceId != null) {
            if(deviceId.contains("Red")) {
                locationTxt.setTextColor(getResources().getColor(R.color.redPrimary));
                locationTxt.setText(deviceId.replace("Red", "Red "));
            } else {
                locationTxt.setTextColor(getResources().getColor(R.color.colorPrimary));
                locationTxt.setText(deviceId.replace("Blue", "Blue "));
            }
        }
    }
}
