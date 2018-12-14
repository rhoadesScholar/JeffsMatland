function gmail(recipient,subject,message,sender,passwd,delhist)
% function gmail(recipient,subject,message,sender,passwd,delhist)
%
%GMAIL  A wrapper for MATLAB's sendmail that handles the gmail server
% GMAIL(recipient,subject,message,sender,passwd) will send an email message
% message to recipient with subject subject using the gmail account of
% sender@gmail.com whose password is passwd. If the optional delhist
% is true the command history file will be deleted.
%
% Remarks: The sendmail function will not work with a gmail account without
% some modification. The gmail server uses secure authentication and
% requires a user and password and some changes to the port and SSL
% settings. The doc page for sendmail explains how to do this. Two obvious
% problems are: (1) the preferences where username and password are saved
% are persistent and kept in an unsecure file on your hard drive - a bad
% idea. (2) the port and SSL setting are not persistent and need to be
% reset for each MATLAB session. GMAIL acts as a wrapper to sendmail that
% sets these values, sends an email, and then erases the user and password
% values. It is not ultra-secure but at least your password is not saved in
% a plain text file. Keep in mind though that your password string now
% exists in the command history! So an optional last argument allows you to
% delete the command history file after completion. (Note: I don't know how
% to delete just the last command without a long edit of the file.)
%
% Author: Naor Movshovitz, edited by Navin 10/22/10

% sigh, argument checking...
error(nargchk(5,6,nargin));
if nargin==5, delhist=false; end
if ~islogical(delhist), error('delhist must be logical'), end
if ~ischar(recipient), error('recipient must be email address'), end
if ~ischar(subject), error('subject must be string'), end
if ~ischar(message), error('message must be string'), end
if ~ischar(sender), error('sender must be gmail email address'), end
if ~ischar(passwd), error('password must be string'), end
%...more argument checking here...

% complete sender to sender@gmail.com if necessary (but don't be a dick and
% put @gmail.com in the middle of an illegal address...)
if isempty(findstr(sender,'@gmail.com'))
    sender=[sender '@gmail.com'];
end
validemail='[a-z_.1-9]+@[a-z_.1-9]+\.(com|net|edu)';
imatch=regexp(sender,validemail);
if isempty(imatch) || ~isscalar(imatch) || imatch>1
    error('not a valid email address')
end

% set mail preferences
setpref('Internet','SMTP_Server','smtp.gmail.com')
setpref('Internet','E_mail',sender)
setpref('Internet','SMTP_Username',sender)
setpref('Internet','SMTP_Password',passwd)

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', ...
                  'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

% send the message
try
    sendmail(recipient,subject,message)
catch ME
    disp(ME.message)
    fprintf('...erasing private data\n')
end

% and erase the record
setpref('Internet','SMTP_Server','')
setpref('Internet','E_mail','')
setpref('Internet','SMTP_Username','')
setpref('Internet','SMTP_Password','')
clc
if delhist
    com.mathworks.mlservices.MLCommandHistoryServices.removeAll
else
    warning('command history may contain your password!')
end
