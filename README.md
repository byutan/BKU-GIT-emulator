# 🔵⚪🔵 BKU-GIT-emulator 🔵⚪🔵 
<p><i>A simple git emulator, executable only on Ubuntu. The source code is open for modifying and using.</i></p>
<i>By <b>HUU THANG NGUYEN.</b></i>
<h1><b><center>MANUAL</b></h1>
<h2><b>1. SETUP</b></h2>
<p><b>bash setup.sh --install:</b> begin installing dependencies and packages.</p>
<p><b>bash setup.sh --uninstall:</b> begin uninstalling all of dependencies, packages, intialised folders and files.</p>
<h2><b>2. INITIALISING</b></h2>
<p><b>bku init:</b> Initialise hidden <i>.bku</i> folder, along with <i>tracked_files</i> (storing commited files), <i>diff</i> folders (saving changes) and a history log within the <i>.bku</i> folder.</p>
<h2><b>3. ADDING</b></h2>
<p><b>bku add (filepath):</b> Copy the chosen file and save to <i>tracked_files</i> folders.</p>
<p><b>bku add:</b> Copy all of files within working directory excluding <i>.bku</i> folder and save to <i>tracked_files</i> folders.</p>
<h2><b>4. STATUS</b></h2>
<p><b>bku status (filepath):</b> Show changes happened with chosen file and its commited version in <i>tracked_files</i> folders.</p>
<p><b>bku status:</b> Show changes happened with all of the files and its commited versions in <i>tracked_files</i> folders.</p>
<h2><b>5. COMMITTING</b></h2>
<p><b>bku commit (message) (filepath):</b> Saving changes with the chosen file to a <i>.diff</i> file and log message into history log file.</p>
<p><b>bku commit (message):</b> Saving changes with all of the files to <i>.diff</i> files and log messages into history log file.</p>
<h2><b>6. RESTORING</b></h2>
<p><b>bku restore (filepath):</b> Revert the chosen file to its latest commited version.</p>
<p><b>bku restore:</b> Revert all files to its latest commited versions.</p>
<h2><b>7. HISTORY</b></h2>
<p><b>bku history:</b> Print to terminal history log.</p>
<h2><b>8. SCHEDULING</b></h2>
<p><b>bku schedule --hourly/--daily/--weekly/--off:</b> Automatically commits of all changed tracked files or disable scheduling itself.</p>
