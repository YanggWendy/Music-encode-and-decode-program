decode_word = {'start-','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t',...
  'u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P'...
  ,'Q','R','S','T','U','V','W','X','Y','Z','[',']',':',',','.',' ','!','~','`',';','?','-','"','''','2','1','0','8','-end'};
freq = 10000;
FreqStep = 100;
decode_freq = [9000 freq : FreqStep : freq+(length(decode_word)-2)*FreqStep-FreqStep 8900];
decode_dic = containers.Map(decode_freq,decode_word);

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



%split the music array
freq_sample = 44100;
period = 0.05;
chunk_len = int32(freq_sample*period);
chunk_num = idivide(length(record_mu),chunk_len);

%highpass
highpass(record_mu,10000,freq_sample);
record_mu_filter = highpass(record_mu,10000,freq_sample);

%check the music after hpf
figure
plot(record_mu_filter)

%sliding window to get the point where decode starts
if(0)
    value = 0;
    for k = 0:150000
        time_interval = 0.0001;
        incre = int32(freq_sample*time_interval*k);
        sound = record_mu_filter(1+incre:incre+chunk_len);
        sound_fft = fft(sound, 2^nextpow2(length(sound)));
        mx = max(abs(sound_fft));
        idx = find(abs(sound_fft)==mx);
        delFreq = freq_sample / length(sound_fft);
        start_freq = (idx(1)-1).*delFreq;
        if start_freq >= 9000 & start_freq <= 9010
            value = k-199;
        end

    end
end 

if(1)
    value = 0;
    for k = 0:150000
        time_interval = 0.0001;
        incre = int32(freq_sample*time_interval*k);
        sound = record_mu_filter(1+incre:incre+chunk_len);
        sound_fft = fft(sound, 2^nextpow2(length(sound)));
        mx = max(abs(sound_fft));
        idx = find(abs(sound_fft)==mx);
        delFreq = freq_sample / length(sound_fft);
        start_freq = (idx(1)-1).*delFreq;
        if start_freq >= 9000 & start_freq <= 9010
            value = k-198;
            break
        end

    end
end 
start_value =value*time_interval - 0.05*floor(value*time_interval/0.05);
disp('value')
disp(value)
disp('start_value')
disp(start_value)
start_chunk = start_value*freq_sample;


%decode the message
sound = [];

deccode_mssg = [];
flag = 0;
adjust = 0;
for i = 1:(chunk_num-1)
    start_point = start_chunk+1+(i-1)*chunk_len+400;
    end_point = start_chunk+(i)*chunk_len-400;
    sound = record_mu_filter(start_point:end_point);
    sound_fft = fft(sound, 2^nextpow2(length(sound)));

    [max_v, index] = maxk(abs(sound_fft),6);
    
    mx = max(abs(sound_fft));
    idx_detect = find(abs(sound_fft)> 0.5*mx);
    idx = find(abs(sound_fft)==mx);
    delFreq = freq_sample / length(sound_fft);

    fTemp = (idx(1)-1).*delFreq;
    fTemp = FreqStep*round(fTemp/FreqStep);
    
    fTemp_2 = (index(3)-1).*delFreq;
    fTemp_2 = FreqStep*round(fTemp_2/FreqStep);
    
    fTemp_3 = (index(5)-1).*delFreq;
    fTemp_3 = FreqStep*round(fTemp_3/FreqStep);

    if fTemp == 9000
        flag = 1;
        decode_word = decode_dic(fTemp);
        deccode_mssg = [deccode_mssg decode_word];
    end

    if fTemp == 8900
        flag = 0;
        decode_word = decode_dic(fTemp);
        deccode_mssg = [deccode_mssg decode_word];
        break
    end

    if(flag)
        if any(decode_freq(:) == fTemp)
            if fTemp == 9000
                continue
            end
            decode_word = decode_dic(fTemp);
            
            if length(idx_detect)>2 & deccode_mssg(end) == decode_word
                if any(decode_freq(:) == fTemp_2) & fTemp_2~=fTemp
                    decode_word = decode_dic(fTemp_2);
                    deccode_mssg = [deccode_mssg decode_word]; 
                    continue
                end
                step_1 = 0.02*freq_sample;
                sound_next = record_mu_filter(start_point+step_1:end_point+step_1);
                sound_next_fft = fft(sound_next, 2^nextpow2(length(sound_next)));
                [max_v_c, index_c] = maxk(abs(sound_next_fft),6);
                mx_c = max(abs(sound_next_fft));
                idx_detect_c = find(abs(sound_next_fft)> 0.5*mx_c);
                idx_c = find(abs(sound_next_fft)==mx_c);
                delFreq = freq_sample / length(sound_next_fft);
                fTemp_next = (idx_c(1)-1).*delFreq;
                fTemp_next = FreqStep*round(fTemp_next/FreqStep);
                if any(decode_freq(:) == fTemp_next) & fTemp_next~=fTemp
                    decode_word = decode_dic(fTemp_next);
                    deccode_mssg = [deccode_mssg decode_word]; 
                    continue
                end
            end 
            deccode_mssg = [deccode_mssg decode_word];
        elseif any(decode_freq(:) == fTemp_2)
            decode_word = decode_dic(fTemp_2);
            deccode_mssg = [deccode_mssg decode_word]; 
        elseif any(decode_freq(:) == fTemp_3)
            decode_word = decode_dic(fTemp_3);
            deccode_mssg = [deccode_mssg decode_word]; 
        end      
    end
    
end


count = 0;
test_mssg = erase(deccode_mssg,"start-");
test_mssg = erase(test_mssg,"-end");

for j = 1:min(length(readMsg),length(test_mssg))
    if readMsg(j) == test_mssg(j)
        count=count+1;
    end 
end
accu = count/length(readMsg);

disp("accu")
disp(accu) 

disp('deccode_mssg')
disp(deccode_mssg)

fname = 'A0247305J_Yang wenting_decodedMessage.txt';
fid = fopen(fname,'w');
msg = deccode_mssg;
fprintf(fid,'%s', msg);
fclose(fid);