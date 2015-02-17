#!/usr/bin/perl

# Copyright 2012 Nikolai Ozerov (VE3NKL)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# If necessary you can customize your installation by changing the 
# following variables:

$srv_name  = '';                      # Server name or empty string for auto-detect
$self_addr = '/cgi-bin/hamchat.pl';   # URL path to this script
$css_addr  = '/hamchat/styles.css';   # Absolute path to the css styles file
$dir_name  = '/www/hamchat/data';     # Absolute path to the data directory
$lock_name = 'lock';                  # Name of the lock file inside the directory
$max_file_size = 5;                   # Maximum number of messages per file
$max_files     = 10;                  # Maximum number of files

# ---------------------------------------------------------------------------- #

read_form_vars();

if ($srv_name eq '') {
  chomp ($srv_name = `uname -n`);
}

$post_request_type = '';
if (defined $parms{request_type}) {
  $post_request_type = $parms{request_type};
};

$post_callsign = '';
if (defined $parms{callsign})  {
  if (length(trim($parms{callsign})) <= 6 && length(trim($parms{callsign})) >=3) {
    $post_callsign = trim($parms{callsign});
  }
};

if (defined $parms{message}) {
  $post_message = $parms{message};
};
 
if ($post_request_type eq 'connect') {

# Here we have been send a callsign. Check that it is correct.

  if (length($post_callsign) > 0) {
    
    &display_chat($post_callsign, 'AutoRefresh');
    
  } else {
    
    &display_login('Invalid Callsign. Please, enter your valid Callsign.');
    
  }

} elsif ($post_request_type eq 'message') {

  if (length($post_callsign) == 0) {
    
    &display_login('');
    
  } else {

    if (length($post_message) > 0) {
      &write_msg($post_callsign, $post_message);
    };
   
    &display_messages();
      
  };
    
} else {

# In all other cases ask about callsign ...

  &display_login('');
  
};

#-------------------------------------------------+
# Write a new message into one of the data files. |
#-------------------------------------------------+ 

sub write_msg {

  $name = $_[0];  # User name (callsign)
  $msg  = $_[1];  # The new message

# First of all obtain an exclusive lock on a special 'lock' file to prevent possible
# interfearing with another thread.

  open(LOCK, '<' . $dir_name . '/' . $lock_name);
  
  if (flock(LOCK, 2)) {    

# Read file names in the data directory

    opendir(my($handle), $dir_name);
    my @files = readdir($handle);
    @files = sort(@files);
    closedir($handle);

# Remove '.', '..' and 'lock' entries. What's left are the names of our data files.

    my $n_files = @files;
    my $i;
    for($i = $n_files - 1; $i >= 0; $i --) {
      if ((@files[$i] eq '.') || (@files[$i] eq '..') || (@files[$i] eq $lock_name)) {
        splice(@files, $i, 1);
      }
    }
    $n_files = @files;

# Each data file has a name of the following form:
#    data_999999999999_9..9
# where the first group of 12 digits represents UNIX epoch time and the second group of
# variable number of digits represents the number of messages written into this file.
# Here we obtain the last file name and its size as the number of messages it contains.    

    my $last_file = @files[-1];
    my $text = $last_file;
    $text =~ m/^(data_\d+)_(\d+)$/;
    my $last_file_pref = $1;
    my $last_file_size = $2;

# Now we write our message either into the last file or into a new file we create.
# We create the file only if there is no other data files or if the last file already
# has enough messages.
    
    my $current_file;
 
    if (($n_files == 0) || ($last_file_size >= $max_file_size)) {
      my $datetime = time();
      $current_file = 'data_' . sprintf("%012d", $datetime) . '_1';
    } else {
      $current_file = $last_file;
    };

    my $current_path = $dir_name .  '/' . $current_file;
    
    if ($current_file eq $last_file) {
		  open(FILE, ">>$current_path");
		} else {
		  open(FILE, ">$current_path");
		}
    
    printf FILE '<p><span class="callsign">' . $name . ':</span><span class="message">' . special_chars($msg) . '</span></p>' . "\r\n";
    close(FILE);

# If we appended the message to the last file we need to rename it to reflect the new
# number of messages it contains.

    if ($current_file eq $last_file) {  # if we wrote it into an existing file we have to rename it
      $last_file_size ++;
      my $new_file = $last_file_pref . '_' . $last_file_size;
      rename $dir_name . '/' . $last_file, $dir_name . '/' . $new_file;
    }

# If the total number of data files if greater than maximum allowed, remove
# the oldest files.

    my $n = $n_files;
    if ($current_file ne $last_file) {
      $n ++;
    };

    if ($n > $max_files) {
      for ($i = 0; $i < ($n - $max_files); $i++) {
        unlink($dir_name .  '/' . @files[$i]);
      };
    };
      
  };

# We are done and can release the lock now.

  close(LOCK);      

}

#-------------------+
# Reading the data. |
#-------------------+ 

sub read_data {

# First of all obtain an exclusive lock on a special 'lock' file to prevent possible
# interfearing with another thread.  

  open(LOCK, '<' . $dir_name . '/' . $lock_name);
  
  if (flock(LOCK, 2)) {

# Read all file names in the data directory. Sort the names so that the
# oldest files come first and most recent files are at the end.

    opendir(my($handle), $dir_name);
    my @files = readdir($handle);
    @files = sort(@files);
    closedir($handle);              

# Read data from all data files and send them to the client.

    foreach $file(@files) {
      if (($file ne '.') && ($file ne '..') && ($file ne $lock_name)) {
        my $path = $dir_name . '/' . $file;
        open(HFILE, $path) or die $!;
        while(my $line=<HFILE>) {
          print $line;
        }
        close(HFILE);
      }
    }
  };

# We are done and can release the lock now.
  
  close(LOCK);    
}

# Display login page.

sub display_login {
  $errmsg = $_[0];
  print "HTTP/1.0 200 OK\r\nContent-type: text/html\r\n";
  print "Cache-Control: no-store\r\n";
  print "\r\n";
  print '  <html>';
  print '  <head><title>Connect to HamChat Server</title>';
  print '    <link rel="stylesheet" type="text/css" href="' . $css_addr . '">';
  print '  </head>';
  print '  <body onload="document.login.callsign.focus();" class="page1">';
  print '    <div class="screen">';
  print '    <div class="title">Enter your callsign, please.</div>';
  print '    <div class="sender">';
  print '      <p>Use your callsign without any modifiers (such as portable, etc).</p>';
  if (length($errmsg) > 0) {
    print '      <p>' . $errmsg . '</p>';
  }
  print '      <form name="login" action="' . $self_addr . '" method="post">';
  print '        <input type="hidden" name="request_type" value="connect" />';
  print '        <table>';
  print '           <tr><td>Your callsign: </td>';
  print '          <td><input class="text" type="text" name="callsign" /></td>';
  print '          <td><input class="text" type="submit" name="submit" value="Connect" /></td></tr>';
  print '        </table>';
  print '      </form>';
  print '    </div>';
  print '    <div class="copyright">(C) Copyright 2012, VE3NKL</div>';
  print '  </div>';
  print '</body>';
  print '</html>';

}

sub display_messages {
  print "HTTP/1.0 200 OK\r\nContent-type: text/html\r\n";
  print "Cache-Control: no-store\r\n";
  print "\r\n";
  print ' <html>';
  print '   <head><title>HamChat Server</title>';
  print '     <link rel="stylesheet" type="text/css" href="' . $css_addr . '">';
  print '     <script lang="JavaScript">';
  print '       function frameReady() {';
  print '         window.scrollTo(0, 5000);';
  print '       }';
  print '     </script>';
  print '   </head>';
  print ' <body class="page2" onload="frameReady();">';
  &read_data();
  print ' </body>';
  print ' </html>';
}


# Display Chat page.

sub display_chat {
  my $callsign = $_[0];
  my $refresh  = $_[1];
  my $chk;
  my $rfr;
  if ((defined $refresh) && ($refresh ne '')) {
    $chk = ' checked="checked"';
    $rfr = '1';
  } else {
    $chk = "";
    $rfr = '0';
  };
  print "HTTP/1.0 200 OK\r\nContent-type: text/html\r\n";
  print "Cache-Control: no-store\r\n";
  print "\r\n";
  print ' <html>';
  print '   <head><title>HamChat Server</title>';
  print '     <link rel="stylesheet" type="text/css" href="' . $css_addr . '">';
  print '     <script lang="JavaScript">';
  print '       var AutoRefresh = ' . $rfr .';';
  print '       function startTimer() {';
  print '         document.refresh.submit();';
  print '         setInterval("refresh()", 2000);';
  print '         document.getElementById("form-sender").onsubmit=aboutToSubmit;';
  print '       }';
  print '       function checkboxClicked() {';
  print '         var cb = document.getElementById("cb-auto");';
  print '         if (cb.checked) {';
  print '           AutoRefresh = 1;';
  print '         } else {';
  print '           AutoRefresh = 0;';
  print '         }';
  print '       }';
  print '       function refresh() {';
  print '         if (AutoRefresh == 1) {';
  print '           document.refresh.submit();';
  print '         }';
  print '       }';
  print '       function aboutToSubmit() {';
  print '         document.getElementById("snd-message").value=document.getElementById("txt-message").value;';
  print '         document.getElementById("txt-message").value="";';
  print '         return true;';
  print '       }';
  print '     </script>';
  print '   </head>';
  print ' <body onload="document.sender.text.focus();startTimer();" class="page1">';
  print '   <div class="screen">';
  print '     <div class="title">Chat Room on the Server ' . $srv_name . '</div>';
  print '     <div class="messages" id="messages">';
  print '       <iframe id="result" name="result" class="frame">';
  print '       </iframe>';
  print '     </div>';
  print '     <div class="sender">';
  print '       <form name="sender" action="' . $self_addr . '" method="post" target="result" id="form-sender">';
  print '         <input type="hidden" name="request_type" value="message" />';
  print '         <input type="hidden" name="callsign" value="' . $callsign . '" />';
  print '         <span class="message">Type in your message and press SEND:</span>';
  print '         <input type="hidden" name="message" id="snd-message" />';
  print '         <input class="longtext" type="text" name="text" id="txt-message" />';
  print '         <input type="text" name="unused" style="display: none" size="1"/>';
  print '         <input type="submit" name="submit" value="Send" id="ff_send" onfocus="document.sender.text.focus();"/><br/>';
  print '         <span class="control"><input type="checkbox" id="cb-auto" name="auto" value="AutoRefresh" onclick="checkboxClicked();" ' . $chk . '>Auto-Refresh</span>';
  print '         <span class="message">To refresh manually press SEND with no text entered.</span><br/>';
  print '       </form>';
  print '       <form name="refresh" action="' . $self_addr . '" method="post" target="result">';
  print '         <input type="hidden" name="request_type" value="message" />';
  print '         <input type="hidden" name="callsign" value="' . $callsign . '" />';
  print '         <input type="hidden" name="auto" value="AutoRefresh" />';
  print '         <input type="hidden" name="message" value=""/>';
  print '       </form>';
  print '     </div>';
  print '     <div class="copyright">(C) Copyright 2012, VE3NKL</div>';
  print '   </div>';
  print ' </body>';
  print ' </html>';
}

#------------------------------------+
# Miscelleneous service subroutines. |
#------------------------------------+

# Strip all leading and trailing spaces

sub trim($) {
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

# Take care of special HTML characters

sub special_chars {
  my $string = $_[0];
  $string =~ s/&/&#38;/g;      
  $string =~ s/\"/&#34;/g;    
  $string =~ s/\'/&#39;/g;    
  $string =~ s/>/&#62;/g;  
  $string =~ s/</&#60;/g;
  return $string;
}

# Read form variables

sub read_form_vars {

  if ( $ENV{'REQUEST_METHOD'} eq "POST" ) {
    my $form;
    read(STDIN, $form, $ENV{'CONTENT_LENGTH'});

    foreach $pair (split('&', $form)) {
      if ($pair =~ /(.*)=(.*)/) {        # Here we have key=value pair
        ($key, $value) = ($1, $2);       # Retrieve them
         $value =~ s/\+/ /g;             # Replaces + signs with spaces
         $value =~ s/%(..)/pack('c',hex($1))/eg;
         $parms{ $key } = $value;        # Put Key/Value into Hash
      }
    };
  };

}
