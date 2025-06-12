README.txt

## MATLAB Baseball Motion Analysis App

This MATLAB application provides a comprehensive platform for visualizing and analyzing human motion data, particularly focusing on baseball-related movements. The app allows users to explore 3D body plots, analyze joint angles, and perform spectrum analysis on selected data.

### Features:

* **Export Data (Generate PDF):**
    Click the "Export Data (Generate PDF)" button to generate a PDF document containing all local Frames: Euler/cardan angles, velocities and accelaration graphs.
* **3D Man Plot:**
    Visualize the entire baseball player's motion in 3D space, reconstructed from input `.tsv` data files.
    * **Time Slider:** Use the slider to navigate through different time points of the motion, observing the player's posture at specific instances.
    * **Play Animation:** Click "Play Animation" to animate the 3D man plot from the current time slider position, providing a dynamic view of the movement.

* **3D Body Part Plot & Angle Analysis:**
    Select a specific body part from the dropdown menu below the 3D Man Plot. This feature offers a detailed analysis of the chosen body part's movement:
    * The plot will display the initial full body posture, the movement trajectory of the selected body part over time (with different points represented by various colors), and the final full body posture.
    * Corresponding plots for **Flexion Angles**, **Abduction Angles**, and **Axial Rotation Angles** (likely Euler angles) of the selected body part will be displayed, providing quantitative insights into its motion.

* **Data Section - Spectrum Analysis:**
    This section presents a **Spectrum Analysis** plot, visualizing the power distribution across different frequencies of the motion data.

* **Data Section - Local Frame Analysis (Phase Plots):**
    Further analysis in the Data section includes two specialized plots for understanding the relationship between different body segments:
    * **Local Frame Choice 1 & 2 Dropdowns:** Select two local frames (e.g., "upper arm," "forearm") from the dropdown menus.
    * **On which axis? Dropdown:** Choose the desired axis (e.g., 'X', 'Y', 'Z') for the analysis.
    * Based on your selections, the app will generate two plots:
        * **Angle-Velocity Phase Plane:** Illustrates the relationship between the angle and angular velocity of the chosen local frames, which is useful for understanding joint dynamics.
        * **Continuous Relative Phase over Time:** Shows how the phase relationship between the two selected local frames changes over the duration of the movement.

### Getting Started:

1.  Ensure you have MATLAB installed.
2.  Open the `MATLAB App` file (or the main script/function if it's not packaged as a standalone app).
3.  Load your `.tsv` motion data file if prompted, or ensure it's in the expected directory.
4.  Explore the various features using the provided controls.

### Data Requirements:

This application is designed to work with motion data provided in a `.tsv` file format. The structure of the `.tsv` file should be consistent with the data expected by the application for accurate visualization and analysis.

### System Requirements:

* **Operating System:** Windows (64-bit recommended)
* **MATLAB Runtime:** This application requires the MATLAB Runtime (version matching the MATLAB version used for compilation). The installer for the MATLAB Runtime is usually provided with the compiled application or can be downloaded from the MathWorks website
