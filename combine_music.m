%combine with music
fname = strcat('source_music.wav');
[source_music, Fs_source] = audioread(fname);

fname = strcat('encode music.mp4');
[encode_music, Fs_encode] = audioread(fname);

lowpass(source_music,5000,Fs_source);
source_music = lowpass(source_music,5000,Fs_source);

%source: https://in.mathworks.com/matlabcentral/answers/223712-making-two-different-vectors-the-same-length
maxlen = max(length(source_music), length(encode_music));

encode_music_c = source_music;
start_point = int32(length(source_music)/3);
encode_music_c(1:start_point) = 0;
encode_music_c(start_point+1:start_point+length(encode_music)) = encode_music;
encode_music_c(end+1:maxlen) = 0;

combined_music = 0.015*encode_music_c+source_music;
cm = audioplayer(combined_music, Fs_source);
audiowrite(strcat("A0247305J_Yang wenting_ musicWithMessage.mp4"),combined_music,Fs_source);
%play(cm)
