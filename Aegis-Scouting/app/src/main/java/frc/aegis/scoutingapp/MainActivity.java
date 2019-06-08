package frc.aegis.scoutingapp;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.prefs.Preferences;

public class MainActivity extends Activity implements View.OnClickListener {
    private Button beginbtn, localbtn;
    private EditText numEntry, roundEntry, authorEntry;
    private RadioButton hab1, hab2, red1, red2, red3, blue1, blue2, blue3;
    private RadioGroup lvlOptions, locSelect;
    private ImageButton preloadbtn, gearbtn;
    private ImageView logo;
    private LinearLayout main, location, preloadLayout, bottom;
    private RelativeLayout full;
    private TextView locationTxt, habLabel, preloadTxt;
    public static TeamEntry teamEntry; //Current Entry
    public static ArrayList<TeamEntry> entryList; //Data
    private boolean errors, midMatch;
    private int preloadStatus, habStart;
    public static String deviceId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        beginbtn = (Button)findViewById(R.id.start_btn);
        localbtn = (Button)findViewById(R.id.local_btn);

        numEntry = (EditText)findViewById(R.id.team_num_entry);
        roundEntry = (EditText)findViewById(R.id.round_entry);
        authorEntry = (EditText)findViewById(R.id.author_entry);

        hab1 = (RadioButton)findViewById(R.id.hab_1);
        hab2 = (RadioButton)findViewById(R.id.hab_2);
        red1 = (RadioButton)findViewById(R.id.red_1);
        red2 = (RadioButton)findViewById(R.id.red_2);
        red3 = (RadioButton)findViewById(R.id.red_3);
        blue1 = (RadioButton)findViewById(R.id.blue_1);
        blue2 = (RadioButton)findViewById(R.id.blue_2);
        blue3 = (RadioButton)findViewById(R.id.blue_3);

        lvlOptions = findViewById(R.id.lvlOptions);
        locSelect = findViewById(R.id.loc_selection);

        preloadbtn = (ImageButton)findViewById(R.id.preload_selection);
        gearbtn = (ImageButton)findViewById(R.id.gear_btn);

        logo = findViewById(R.id.first_logo);

        main = findViewById(R.id.mainLayout);
        location = (LinearLayout)findViewById(R.id.id_bar);
        full = (RelativeLayout)findViewById(R.id.fullLayout);
        full.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                if(Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN) {
                    full.getViewTreeObserver().removeGlobalOnLayoutListener(this);
                }
                else {
                    full.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                    autoSize(main.getHeight(), full.getHeight());
                    System.out.println("I ran");
                }
            }
        });
        preloadLayout = findViewById(R.id.preloadLayout);
        bottom = findViewById(R.id.entry_bottom_panel);

        locationTxt = (TextView)findViewById(R.id.location_txt);
        habLabel = findViewById(R.id.hab_label);
        preloadTxt = findViewById(R.id.preloadTxt);

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
                return;
            }

            teamEntry.setPreload(preloadStatus);
            teamEntry.setHabStart(habStart);

            //Checks for trolls
            errors = !teamEntry.validAuthor() || teamEntry.getAuthor().length() >= 25 || teamEntry.getAuthor().length() <= 0 || teamEntry.getTeamNum() >= 10000 || teamEntry.getTeamNum() <= 0 || teamEntry.getRound() < 0 || deviceId == null || (!hab1.isChecked() && !hab2.isChecked());

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
                        saveLocation();
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
            if ((entryList != null && !entryList.isEmpty()) && deviceId != null){
                AlertDialog.Builder alertDialog = new AlertDialog.Builder(this);
                alertDialog.setTitle("Location Already Entered");
                alertDialog.setPositiveButton("OK", ((dialog, which) -> {
                    dialog.dismiss();
                    return;
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
        editor.commit();
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

    public void autoSize(int mainHeight, int fullHeight) {
        authorEntry.setHeight((int)(mainHeight*.1));
        roundEntry.setHeight((int)(mainHeight*.1));
        numEntry.setHeight((int)(mainHeight*.1));
        ViewGroup.LayoutParams params = preloadLayout.getLayoutParams();
        params.height = (int)(mainHeight*.15);
        habLabel.setHeight((int)(mainHeight*.1));
        params = lvlOptions.getLayoutParams();
        params.height = (int)(mainHeight*.3);
        params.width = RelativeLayout.LayoutParams.MATCH_PARENT;
        params = bottom.getLayoutParams();
        params.height = (int)(mainHeight*.15);
        params = gearbtn.getLayoutParams();
        params.height = (int)(full.getWidth()*.07);
        params.width = (int)(full.getWidth()*.07);
        params = logo.getLayoutParams();
        params.width = (int)(full.getWidth()*.15);
        params.width = (int)(full.getWidth()*.15);
        params = main.getLayoutParams();
        params.width = (int)(full.getWidth()*.5);
        ((RelativeLayout.LayoutParams)main.getLayoutParams()).setMargins(spToPx(10), gearbtn.getBottom(), spToPx(10), spToPx(10));
        params = habLabel.getLayoutParams();
        params.height = (int)(mainHeight*.1);
        params = preloadbtn.getLayoutParams();
        params.width = (int)(main.getWidth()*.4);
        params.height = (int)(main.getWidth()*.4);
        params = preloadLayout.getLayoutParams();
        params.height = preloadbtn.getLayoutParams().height;

    }

    public void onRestart() {
        super.onRestart();
    }

    public void onResume() {
        super.onResume();
    }

    public int spToPx(float sp) {
        return (int)(sp * getResources().getDisplayMetrics().scaledDensity);
    }

}
