
encode_word = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t',...
  'u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P'...
  ,'Q','R','S','T','U','V','W','X','Y','Z','[',']',':',',','.',' ','!','~','`',';','?','-','"','''','2','1','0','8'};
freq = 10000;
FreqStep = 100;
encode_freq = [freq : FreqStep : freq+length(encode_word)*FreqStep-FreqStep];
encode_dic = containers.Map(encode_word, encode_freq);

%generate encode music
if(1)
    fname = 'message_to_be_encoded.txt';
    fid = fopen(fname,'r');
    readMsg = fgetl(fid);
    fclose(fid);
    disp(readMsg)
end 

if(0)
    fname = 'message_test.txt';
    fid = fopen(fname,'r');
    readMsg = fgetl(fid);
    fclose(fid);
    disp(readMsg)
end 


freq_sample = 44100;
timeStep = 1/freq_sample;
encode_music = [];
%insert start signal
period = 0.20;
t = [0 : timeStep : period-timeStep];
freq = 9000;
y = sin(2*pi*freq*t);
encode_music = [encode_music,y];



for i = 1: length(readMsg)
    
    period = 0.0025;
    t = [0 : timeStep : period-timeStep];
    freq = 0;
    y = sin(2*pi*freq*t);
    encode_music = [encode_music,y];
    
    %disp(readMsg(i))
    period = 0.045;
    char = readMsg(i);
    freq = encode_dic(char);
    t = [0 : timeStep : period-timeStep];
    y = sin(2*pi*freq*t);
    encode_music = [encode_music,y];
    
    period = 0.0025;
    t = [0 : timeStep : period-timeStep];
    freq = 0;
    y = sin(2*pi*freq*t);
    encode_music = [encode_music,y];
end

%insert end signal
period = 0.20;
t = [0 : timeStep : period-timeStep];
freq = 8900;
y = sin(2*pi*freq*t);
encode_music = [encode_music,y];

obj = audioplayer(encode_music, freq_sample);
audiowrite(strcat("encode music.mp4"),encode_music,freq_sample);