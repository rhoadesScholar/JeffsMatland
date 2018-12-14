function varargout = webbot(url_name_in, varargin)
%WEBBOT Java-based browser with download and PERL regular expressions
% 
% The function will extract all links from a web-page, and display
% them. The resulting documents can be downloaded.
%
% VERSION 1.0 - 15.10.03
% 
% webbot(URL)            URL is a string indicating the base page
%                        address; the url must link to an html file.
%                        The function lists all links in the file.
%                        URL can also be a cell vector of url-strings.
% webbot(URL, WHAT)      displays only specific links. WHAT is a
%                        string:
%       'all_links'      displays all links (default).
%       'page_links'     displays all links to an html web page*.
%       'local_links'    displays all local links on the server*.
%       'external_links' displays all links to external websites.
%       'image_links'    displays all links to an image file**.
%       'image_tags'     displays all image tags <img src="xxx">.
%       '.xxx.yyyy.zz'   displays all links to each specific .xxx
%                        files; the case is ignored ('zip' will
%                        find 'ZiP'); e.g. '.zip.gz.gzip.tar.Z'.
% webbot(URL, WHAT, ACT) performs an action on found links. ACT is a
%                        string:
%       'noaction'       just display links (default)
%       'download'       downloads all links found locally.
%       'cartoons'       downloads all image tags found on linked
%                        pages. This is usefull for cartoons websites
%                        where each cartoon (e.g. "01.gif") is on its
%                        own html page (e.g. "c01.html").
%       'follow.x'       follows links to html pages and recursively
%                        performs the same action on the resulting page.
%                        'x' is an integer indicating the recursivity
%                        depth (0 is equivalent to 'noaction').
% lks = webbot(URL, ...) returns an cell-array with links of URL{end}.
% 
% Notes: * Links explicitely pointing to a .htm or .html url.
%       ** Image links are recognized by the following file types:
%           .jpg .jpeg .gif .pict .bmp .tif .tiff .ras .png (.giff)
% 
% Try it with:
%   webbot('http://www.unitedmedia.com/comics/dilbert/archive/', ...
%           'local_links', 'cartoons');
% 
% Written by L.Cavin, 28.09.2003, (c) CSE
% This code is free to use and modify for non-commercial purposes.
% Web address: http://ltcmail.ethz.ch/cavin/CSEDBLib.html#WEBBOT

% TARGETS NOT (CORRECTLY) IMPLEMENTED YET:
%       'all_mirror'     combines 'image_tags', 'image_links'
%                        and 'local_links' for mirroring.
% ACTIONS NOT IMPLEMENTED YET:
%       'mirror.x'       downloads all files locally, and follow links
%                        to do it recusively. Will also modify internal
%                        links to the local paths, resulting in a mirror
%                        of the web site on the local computer.
% IMPROVEMENTS TO BE DONE:
%   The binary download is unbuffered, i.e. one byte is read at a time.
%   When I will understand how I can send a java array reference pointer
%   to java, this can be modified (for an expected speed gain of at least
%   factor 5).
%   The return value should be a consolidated list of all links found, not
%   just the ones of the last url visited in the first call.

if ~iscell(url_name_in)
    url_name_c{1} = url_name_in;
else
    url_name_c = url_name_in;
end
    
tmp = size(url_name_c);
if sum(tmp~=1)>1
    warning('CSE:Info', ['The input must be a vector of urls, not a matrix.' ...
            ' Only the largest dimension will be used.']);
end
[tmp, i] = max(tmp);

for kk = 1:size(url_name_c, i)
    url_name = url_name_c{kk};
	disp(' ');
	disp('Analyzing File:');
	disp(['   ' url_name]);
	action = 0;
	if nargin > 1
        if nargin > 2
            if strcmpi(varargin{2}, 'download') 
                action = 1;
            elseif strcmpi(varargin{2}, 'cartoons')  
                action = 2;
                if ~strcmpi(varargin{1}, 'local_links')
                    warning('CSE:Info', 'The ''cartoons'' action can only (and will) be used with the ''local links'' target.');
                    varargin{1} = 'local_links';
                end
            elseif strcmpi(varargin{2}(1:6), 'follow') 
                if eval(varargin{2}(8:end)) > 0
                    action = 1;
                end
            elseif ~strcmpi(varargin{2}, 'noaction')
                warning('CSE:Info', 'The action argument "%s" is not supported. No action will be taken.', varargin{2});
            end
        end
        if strcmpi(varargin{1}, 'page_links')
            regexp1 = '< *[aA] *[hH][rR][eE][fF] *=[^>]*\.[hH][tT][mM][lL]?[^>]*>';
        elseif strcmpi(varargin{1}, 'local_links')
            regexp1 = '< *[aA] *[hH][rR][eE][fF] *= *"? *[^>^:]*.[hH][tT][mM][lL]? *"? *>';
        elseif strcmpi(varargin{1}, 'external_links')
            regexp1 = '< *[aA] *[hH][rR][eE][fF] *= *"? *[hH][tT]{2}[pP]:[/\\]{2}[^>]*>';
        elseif strcmpi(varargin{1}, 'image_links')
            regexp1 = ['< *[aA] *[hH][rR][eE][fF] *=[^>]*\.(([jJ][pP][eE]?[gG])|(([gG]|[tT])[iI][fF]{1,2})|' ...
                    '([bB][mM][pP])|([pP][iI][cC][tT])|([pP][nN][gG])|([rR][aA][sS]))[^>]*>'];
        elseif strcmpi(varargin{1}, 'image_tags')
            regexp1 = '< *[iI][mM][gG] *[sS][rR][cC] *=[^>]*>';
        elseif strcmpi(varargin{1}, 'all_mirror')
            regexp1 = ['((< *[iI][mM][gG] *[sS][rR][cC] *=[^>]*>)|(' ...
                    '< *[aA] *[hH][rR][eE][fF] *=[^>]*\.(([jJ][pP][eE]?[gG])|(([gG]|[tT])[iI][fF]{1,2})|' ...
                    '([bB][mM][pP])|([pP][iI][cC][tT])|([pP][nN][gG])|([rR][aA][sS]))[^>]*>' ...
                    ')|(< *[aA] *[hH][rR][eE][fF] *= *"? *[^>^:]*((.[hH][tT][mM][lL]?)|([/\\])) *"? *>))'];
        elseif strcmp(varargin{1}(1),'.')
            [beg_pat, end_pat] = regexp(varargin{1}, '.\w*');
            regexp1 = [];
            for j = 1:size(beg_pat,2)
                regexp1 = [regexp1 '('];
                for i = 1:(end_pat(j)-beg_pat(j))
                    regexp1 = [regexp1 '[' upper(varargin{1}(beg_pat(j)+i)) lower(varargin{1}(beg_pat(j)+i)) ']'];
                end
                regexp1 = [regexp1 ')|'];
            end
            regexp1 = ['< *[aA] *[hH][rR][eE][fF] *=[^>]*\.(' regexp1(1:end-1) ')[^>]>'];
        else
            if ~strcmpi(varargin{1}, 'all_links')
                warning('CSE:info', 'Unknown selection argument "%s" is ignored. All links will be displayed.', varargin{1});
            end
            regexp1 = '< *[aA] *[hH][rR][eE][fF] *=[^>]*>';
        end
	else
        regexp1 = '< *[aA] *[hH][rR][eE][fF] *=[^>]*>';
	end
	
	disp('Path Information:');
	% ==========================================================
	[beg_pat, end_pat] = regexp(url_name, '[hH][tT]{2}[pP][sS]?:[/\\]{2}[^/^\\^"^ ]*[/\\]');
	if isempty(beg_pat)
        server_path = 'Local Machine';
	else
        server_path = url_name(beg_pat:end_pat-1);
	end
	disp(['   Server: ' server_path]);
	[beg_pat, end_pat] = regexp(url_name, '(([/]|[\\])[^/^\\]*)$');
	base_path = url_name(1:beg_pat(end));
	disp(['   Full:   ' base_path]);
	[beg_pat, end_pat] = regexp(url_name, '[\w&\-]*\.[hHtTmMlL]{3,4}');
	
	
	disp('Links found:');
	% ==========================================================
    try
		url = java.net.URL(url_name);
		is = openStream(url);
		isr = java.io.InputStreamReader(is);
		br = java.io.BufferedReader(isr);
		s = readLine(br);
        lks_size = 0;
        num_lines = 0;
		while ~isempty(s)
            html_line = [s.Char];
            num_lines = num_lines + 1;
            % now trying to support multi-line tags
            has_beg = 0;
            if ~isempty(regexp(html_line, '(< *(([aA])|([iI][mM][gG]))[^>]*)$'))
                has_beg = 1;
            end
            while has_beg
                s = readLine(br);
                html_line2 = [s.Char];
                if ~isempty(findstr(html_line2, '>'))
                    % we have an ending
                    has_beg = 0;
                end
                if ~isempty(regexp(html_line2, '(< *(([aA])|([iI][mM][gG]))[^>]*)$'))
                    % bad luck, a new beginning...
                    has_beg = 1;
                end
                html_line = [html_line ' ' html_line2];
            end
            base_file{num_lines} = html_line;
            [beg_pat, end_pat] = regexp(html_line, regexp1);
            for i = 1:size(beg_pat,2)
                tmp_lks = html_line(beg_pat(i):end_pat(i));
                tmp_lks_f = tmp_lks;
                [bgnp, endp] = regexp(tmp_lks, '[\w/\.\\\?\-&:]{6,}');
                lks_size = lks_size + 1;
                tmp_lks = tmp_lks(bgnp:endp);
                if ~strcmpi(tmp_lks(1:4),'http')
                    % local link. Must make sure we are not having an overkill
                    % i.e. path = yyy.zzz.com/blop/file/xxx and link is /blop/image/xxx
                    % which would lead to yyy.zzz.com/blop/file/blop/image/xxx
                    % when actually the aim is to indicate a link from the root.
                    if strcmp(tmp_lks(1), '/') | strcmp(tmp_lks(1), '\')
                        tmp_lks = [server_path tmp_lks];
                    else
                        tmp_lks = [base_path tmp_lks];
                    end
                end
                lks{lks_size} = tmp_lks;
                disp(['   ' tmp_lks_f ' --> ' tmp_lks]);
            end
            s = readLine(br);
		end
		if lks_size == 0
            disp('   None.');
            action = 0;
            lks = {};
        else
            lks = unique(lks); % removing duplicates (e.g. separator pictures)
		end
    catch
        [beg_pat, end_pat] = regexp(url_name, '[\w\.-\?&$]*\.[\w]{1,4}');
        if ~isempty(beg_pat)
            fl_nme = url_name(beg_pat(end):end_pat(end));
        else
            fl_nme = url_name;
        end
        disp(['   ERROR: Cannot connect to "' fl_nme '".']);
        try
            if isempty(lks)
                action = 0;
                lks = {};
            end
        catch
            action = 0;
            lks = {};
        end
    end
	lks_size = 0;
	
	
	% output and leave if no action:
	% ===============================================
	if nargout > 0
        varargout{1} = lks;
	end
	
    if action
		if strcmpi(varargin{2}, 'cartoons')
            % make a new folder:
            if strcmpi(server_path(1:4), 'http')
                tmp = regexprep(server_path(8:end),'\.','_');
            else
                tmp = 'local';
            end
			n = 1;
			while prod(size(dir([tmp '-' int2str(n)]))) > 0
                n = n + 1;
			end
			mkdir([tmp '-' int2str(n)]);
			cd([tmp '-' int2str(n)]);
			disp('Download destination: ');
			disp(['   ' pwd]);
            % we have a list of urls to search for cartoons pictures:
            webbot(lks, 'image_links', 'download');
            cd ..
       %elseif strcmpi(varargin{2}(1:6), 'mirror')
            % so, first download local file:
            % base_file{:} contains it in text mode
        elseif strcmpi(varargin{2}(1:6), 'follow')
            rec = eval(varargin{2}(8:end))-1;
            if rec == 0
                cmd = 'noaction';
            else
                cmd = [varargin{2}(1:7) int2str(rec)];
            end
            webbot(lks, varargin{1}, cmd);
        elseif strcmpi(varargin{2}, 'download')
			% Local download:
			% ==============================================
            cd_pp = 0;
			if size(lks,2) > 1
                if strcmpi(server_path(1:4), 'http')
                    tmp = regexprep(server_path(8:end),'\.','_');
                else
                    tmp = 'local';
                end
				n = 1;
				while prod(size(dir([tmp '-' int2str(n)]))) > 0
                    n = n + 1;
				end
				mkdir([tmp '-' int2str(n)]);
				cd([tmp '-' int2str(n)]);
                cd_pp = 1;
            end
			disp('Download destination: ');
			disp(['   ' pwd]);
			disp('Downloading Files:');
            % first we download the actual file...
            src_fle = regexprep(url_name(8:end),'\.','_');
            src_fle = regexprep(src_fle,'\\','_');
            src_fle = regexprep(src_fle,'/','_');
            src_fle = regexprep(src_fle,':','');
            src_fle = regexprep(src_fle,'\s','_');
            src_fle = ['_SRC_' src_fle '_.html'];
            fid = fopen(src_fle, 'wt');
            if fid > 0
                disp(['   [SRC]: ' src_fle '.']);
                for j = 1:prod(size(base_file))
                    fprintf(fid, '%s\n', base_file{j});
                end
                fclose(fid);
            else
                disp(['   Cannot make a local copy of source in ' src_fle]);
            end
            % than the targets:
			for j = 1:size(lks,2)
                [beg_pat, end_pat] = regexp(lks{j}, '[\w\.\-\?&$]*\.[\w]{1,4}');
                fl_nme = lks{j}(beg_pat(end):end_pat(end));
                [beg_pat, end_pat] = regexp(fl_nme, '\.(([hH][tT][mM][lL]?)|([tT][eE]?[xX][tT])|([pP][lL])|([mM]))\>');
                if strcmp(lks{j}(end), '/') | strcmp(lks{j}(end), '\') | ...
                        strcmp(lks{j}(end-3:end), '.com') | strcmp(lks{j}(end-3:end), '.org') | ...
                        strcmp(lks{j}(end-3:end), '.net') | strcmp(lks{j}(end-2:end), '.au') | ...
                        strcmp(lks{j}(end-2:end), '.ch') | strcmp(lks{j}(end-2:end), '.de') | ...
                        strcmp(lks{j}(end-2:end), '.fr') | strcmp(lks{j}(end-2:end), '.uk')
                    % very bad comparision strings... try to find a kool regular expression!
                    
                    % index file (actually, link is to a directory or a server):
                    fl_nme = 'index.html';
                    beg_pat = 1; % text mode
                end
                tic;
                if prod(size(dir(fl_nme))) == 0
                % OK, I am dense. I actually just discovered the java
                % object .getInterruptibleStreamCopier and the matlab
                % function urlwrite. I guess the code below remains cool
                % and informative, but of course we will now replace it
                % with the proper matlab call - and I thought I was smart
                % :-(
                if ~isempty(beg_pat)
                    disp(['   [TXT]: ' lks{j}]);
                else
                    disp(['   [BIN]: ' lks{j}]);
                end
                [f, status] = urlwrite(lks{j}, fl_nme);
                if status > 0
                    disp(['          Saved as ' f]);
                else
                    disp(['          ' lasterr]);
                end
%                 try
% 					url = java.net.URL(lks{j});
%                     if ~isempty(beg_pat)
%                         % download text
% 					    is = openStream(url);
%                         disp(['   [TXT]: ' lks{j}]);
%                         fle_size = is.available;
%                         txtwaitbar(fl_nme, fle_size, 0, 0);
% 						isr = java.io.InputStreamReader(is);
% 						br = java.io.BufferedReader(isr);
%                         flID = fopen(fl_nme, 'wt');
% 						s = readLine(br);
%                         cnt = 0;
% 						while ~isempty(s)
%                             html_line = [s.Char];
%                             fprintf(flID,'%s\n',html_line);
%                             cnt = cnt + prod(size(html_line));
%                             s = readLine(br);
%                             if floor(cnt/fle_size*10) == cnt/fle_size*10
%                                 txtwaitbar(fl_nme, fle_size, cnt, 0);
%                             end
%                         end
%                         fclose(flID);
%                         isr.close;
%                         br.close;
%                     else
%                         % download binary
%                         con = url.openConnection;
%                         is = con.getInputStream;
%                         fle_size = con.getContentLength;
%                         os = java.io.FileOutputStream(fl_nme);
%                         disp(['   [BIN]: ' lks{j}]);
%                         txtwaitbar(fl_nme, fle_size, 0, 0);
%                         bytes_read = is.read;
%                         cnt = 1;
%                         while bytes_read ~= -1
%                             os.write(bytes_read);   
%                             bytes_read = is.read;
%                             cnt = cnt + 1;
%                             if abs(floor(cnt/fle_size*15)-cnt/fle_size*15)<1e-3
%                                 txtwaitbar(fl_nme, fle_size, cnt, 0);
%                             end
%                         end
%                         os.close;
%                         is.close;
%                     end
%                     txtwaitbar(fl_nme, fle_size, fle_size, toc);
% 				catch
%                     disp(['   Error while attempting to download "' fl_nme '": FILE NOT AVAILABLE.']);
%                 end % try
                else
                    disp(['   Error while attempting to download "' fl_nme '": FILE ALREADY DOWNLOADED.']);
                end
			end % for each lks
        if cd_pp
            cd ..
        end
		end % action type (download)
    end % action
end % for each url

%===============================================================
function txtwaitbar(fl_nme, totsiz, done, time_sec);

if done == 0
    rem = ['          Download "' fl_nme '" (' int2str(totsiz/1024) ' kb) [%s]   %d%s'];
else
    if floor(done/totsiz*100)>99
        rem = [repmat('\b', 1, 23) '[%s] %d%s'];
    elseif floor(done/totsiz*100)>9
        rem = [repmat('\b', 1, 23) '[%s]  %d%s'];
    else
        rem = [repmat('\b', 1, 23) '[%s]   %d%s'];
    end
end
if done ~= totsiz
    adv = [repmat('=', 1, floor(done/totsiz*15)) repmat(' ', 1, 15-floor(done/totsiz*15))];
    disp(sprintf(rem, adv, floor(done/totsiz*100), '%'));
else
    adv = '==-complete-===';
    if time_sec > 0
        rem = [rem(1:end-5) ' (' num2str(time_sec) 's; ' num2str(totsiz/1024/time_sec) ' Kb/s).'];
        disp(sprintf(rem, adv));
    else
        disp(sprintf(rem, adv, floor(done/totsiz*100), '%'));
    end
end
