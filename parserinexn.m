function [header, data] = parserinexn(navFile)
%RINEXN Reads a RINEX N file (navigation message) and parses the data.
%   Returns <something great!>.

%Trevor Mackessy-Lloyd 09/2017

%% Function: Validate file suffix
if navFile(strlength(navFile)) ~= 'N'
    error(['Function parserinexn: ', ...
           'Input file is not a navigation file.']);
end

%% Function: Main
disp(strcat('Reading RINEX N file: ', navFile, ' ...'))

fid    = fopen(navFile);
[header, verTest, headLines] = parsenheader(fid);
data   = parsendata(fid, verTest, headLines);

disp(header)
fclose(fid);

%% Subfunction: Parse the header
    function [header, verTest, headLines] = parsenheader(fid)
        %need to add switch for compatibility with other rinex versions
        frewind(fid);
        line = fgetl(fid);
        verTest = strip(line( 1: 9));
        frewind(fid);
        switch verTest
            case '3.02'
                % Declare some helper variables
                descriptor = char.empty(0, 20);
                % The entire header is repackaged into one struct
                header = struct('rinexVer' , {}, ...
                                'rinexType', {}, ...
                                'program'  , {}, ...
                                'agency'   , {}, ...
                                'timeStamp', {}, ...
                                'timeZone' , {}, ...
                                'comment'  , {}, ...
                                'ionoCorr' , {}, ...
                                'timeCorr' , {}, ...
                                'leapSec'  , {});
                % Preallocate table for Ionospheric Correction factor
                ionoCorr = table;
                % TODO: Preallocate 7 slots and reshape
                ionoCorrType = {};
                ionoCorrParam1 = [];
                ionoCorrParam2 = [];
                ionoCorrParam3 = [];
                ionoCorrParam4 = [];
                
                % Preallocate table for Time System Correction factor
                timeCorr = table;
                % TODO: Preallocate 9 slots and reshape
                timeCorrType = {};
                timeCorrParam1 = [];
                timeCorrParam2 = [];
                timeCorrParam3 = [];
                timeCorrParam4 = [];
                timeCorrParam5 = [];
                timeCorrParam6 = [];
                
                headLines = 0;
                i = 0;
                j = 0;
                while not(strcmp(descriptor,'END OF HEADER'))
                    headLines = headLines + 1;
                    line = fgetl(fid);
                    descriptor = strip(line(60:strlength(line)));
                    switch descriptor
                        case 'RINEX VERSION / TYPE'
                            header(1).rinexVer  = strip(line( 1: 9));
                            header(1).rinexType = strip(line(21));
                        case 'PGM / RUN BY / DATE'
                            header(1).program   = strip(line( 1:20));
                            header(1).agency    = strip(line(21:40));
                            header(1).timeStamp = datetime(line(41:55), ...
                                'InputFormat', ...
                                'yyyyMMdd HHmmss');
                            header(1).timeZone  = strip(line(56:59));
                        case 'COMMENT'
                            % TODO: Support multiple comments; do we care?
                            header(1).comment   = strip(line( 1:59));
                        case 'IONOSPHERIC CORR'
                            i = i + 1;
                            ionoCorrType{i}   = strip(line( 1: 4));
                            ionoCorrParam1{i} = strip(line( 6:18));
                            ionoCorrParam2{i} = strip(line(19:30));
                            ionoCorrParam3{i} = strip(line(31:42));
                            ionoCorrParam4{i} = strip(line(43:54));
                        case 'TIME SYSTEM CORR'
                            j = j + 1;
                            timeCorrType{j}   = strip(line( 1: 4));
                            timeCorrParam1{j} = strip(line( 6:23));
                            timeCorrParam2{j} = strip(line(24:39));
                            timeCorrParam3{j} = strip(line(40:46));
                            timeCorrParam4{j} = strip(line(47:51));
                            timeCorrParam5{j} = strip(line(53:57));
                            timeCorrParam6{j} = strip(line(59:60));
                        case 'LEAP SECONDS'
                            leapSec1 = strip(line( 1: 6));
                            leapSec2 = strip(line( 7:12));
                            leapSec3 = strip(line(13:18));
                            leapSec4 = strip(line(19:24));
                        case 'END OF HEADER'
                            %Tidy up Ionospheric & Time System tables
                            ionoCorr.Type   = ionoCorrType';
                            ionoCorr.Param1 = ionoCorrParam1';
                            ionoCorr.Param2 = ionoCorrParam2';
                            ionoCorr.Param3 = ionoCorrParam3';
                            ionoCorr.Param4 = ionoCorrParam4';
                            header(1).ionoCorr = ionoCorr;
                            
                            timeCorr.Type   = timeCorrType';
                            timeCorr.Param1 = timeCorrParam1';
                            timeCorr.Param2 = timeCorrParam2';
                            timeCorr.Param3 = timeCorrParam3';
                            timeCorr.Param4 = timeCorrParam4';
                            timeCorr.Param5 = timeCorrParam5';
                            timeCorr.Param6 = timeCorrParam6';
                            header(1).timeCorr = timeCorr;
                            
                            header(1).leapSec = [leapSec1, leapSec2, ...
                                                 leapSec3, leapSec4];
                        otherwise
                            error(['Function parserinexn: ', ...
                                   'Non-standard 3.02 header line ', ...
                                   'descriptor found.']);
                    end
                end
            otherwise
                error(['Subfunction parsenheader: ', ...
                       'Unsupported RINEX version.']);
        end
    end

%% Subfunction: Parse the data records
    function data = parsendata(fid, verTest, headLines)
        frewind(fid);
        i = 0;
        for i = 1:headLines + 1
            line = fgetl(fid);
        end
        
        data = 'placeholder';
    end
%% Subfunction: Parse one navigation message
    function svMessage = parsenmessage(svLine)
        switch satSystem
            case 'G' % GPS Data Record

            case 'J' % QZSS Data Record
                error(['Subfunction parsenmessage: ', ...
                       'SV Type not supported.']);
            case 'E' % Galileo Data Record
                error(['Subfunction parsenmessage: ', ...
                       'SV Type not supported.']);
            case 'R' % GLONASS Data Record
                error(['Subfunction parsenmessage: ', ...
                       'SV Type not supported.']);
            case 'C' % BDS Data Record
                error(['Subfunction parsenmessage: ', ...
                       'SV Type not supported.']);
            case 'S' % SBAS/QZSS L1 SAIF Data Record
                error(['Subfunction parsenmessage: ', ...
                       'SV Type not supported.']);
            otherwise
                error(['Subfunction parsenmessage: ', ...
                       'Unrecognized SV Type presented.']);
        end
    end
end
% EOF