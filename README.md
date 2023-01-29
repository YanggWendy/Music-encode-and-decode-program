# Music-encode-and-decode-program

# Parameter list:
| Freq_Step  | 100 Hz |
| Start_freq  | 9000 Hz |
| End_freq  | 8900 Hz |
| Each word period  | 0.05s |
| Start period  | 0.15s |
| End period  | 0.15s |

# Algorithm introduction:
For encode part, I used a MATLAB map to assign each character with one frequency(See the table above). And then I generate encode music using [proj_encode.m](https://github.com/YanggWendy/Music-encode-and-decode-program/blob/main/proj_encode.m). After that, I use low pass filter to delete the high frequency in source music and replace it with my encode music. After getting the combined music in [combine_music.m](https://github.com/YanggWendy/Music-encode-and-decode-program/blob/main/combine_music.m), I start to decode the message.

## During encoding
Insert 0 frequency between each word during encoding in order to solve the synchronization problem
## During combine message
Try to insert the music in the middle of the source music so that source music is much louder than encoded music.
## During decode
I save my music into array with every 0.05s time slot. Use the High pass filter to give away low frequency so that I can decode high frequency easier.

# Solve Synchronization Problem
Using Three methods:
1. Give 0 frequency between each word when encoding (mentioned above)
2. Use the sliding window to find a start point 
The accuracy is the best when we find the point where the last point with frequency among 9000 and 9010 minus 199 points is the best time. 199 points mean 0.0199s here and can be different for different time interval. In my project, the time interval is 0.05s
3. Choose the center of each time slot
When we decode, for each time slot we discard the right and left ends data and only use the center. Find 3 Peak and calculate their frequency. Choose one if previous peak’s frequency has no corresponding value in decoding dictionary.

# How to display
1. Encode the message using [proj_encode.m](https://github.com/YanggWendy/Music-encode-and-decode-program/blob/main/proj_encode.m)
2. Combine the encoded music and source music using [combine_music.m](https://github.com/YanggWendy/Music-encode-and-decode-program/blob/main/combine_music.m)
3. Record the music using [record_music.m](https://github.com/YanggWendy/Music-encode-and-decode-program/blob/main/record_music.m)
4. Decode the message using [decode_music.m](https://github.com/YanggWendy/Music-encode-and-decode-program/blob/main/decode_music.m)
