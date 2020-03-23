import sys, os, datetime, time

# create base dir
origin_path = "/home/origin"
transcode_path = "/home/transcode"
uuid = sys.argv[1]
ip = sys.argv[2]
url = sys.argv[3]
name = sys.argv[4]
master_name = sys.argv[5]

if not os.path.isdir(origin_path): os.mkdir(origin_path)
if not os.path.isdir(transcode_path): os.mkdir(transcode_path)

#create master dir
transcode_master_path = f'{transcode_path}/{master_name}'
if not os.path.isdir(transcode_master_path): os.mkdir(transcode_master_path)
origin_master_path = f'{origin_path}/{master_name}'
if not os.path.isdir(origin_master_path): os.mkdir(origin_master_path)

# create uuid dir
transcode_uuid_path = f'{transcode_master_path}/{uuid}'
if not os.path.isdir(transcode_uuid_path): os.mkdir(transcode_uuid_path)
origin_uuid_path = f'{origin_master_path}/{uuid}'
if not os.path.isdir(origin_uuid_path): os.mkdir(origin_uuid_path)

# Download file
def download_file(ip, url, origin_uuid_path):
  cmd = f'scp -oStrictHostKeyChecking=no -i /home/scripts/origin.key -P2022 root@{ip}:{url} {origin_uuid_path}'
  result_download = os.system(cmd)
  if result_download == 0:
    print("File downloaded - " + str(datetime.datetime.now()))
  else:
    print(f'Script has error if download file - {url}, code - {result_download}')
    time.sleep(60)
    download_file(ip, url, origin_uuid_path)

# START SCRIPT COMMANDS

# create status file and set status busy
status_file_path = f'{origin_uuid_path}/status.txt'
f= open(status_file_path,"w+")
f.write("busy")
f.close()

print("Start compress script - " + str(datetime.datetime.now()))
# start download file
download_file(ip, url, origin_uuid_path)

# start command transcode
cmd = f'ffmpeg -i {origin_uuid_path}/{name} -b:v:0 4000k -b:a:0 192k -ac 2 -map 0:v -map 0:a -f hls -var_stream_map "v:0,a:0"  -hls_list_size 0 -master_pl_name master.m3u8 -hls_segment_filename "{transcode_uuid_path}/vs%v/file_%03d.ts" -force_key_frames "expr:gte(t,n_forced*1)" -hls_time 2 {transcode_uuid_path}/vs%v/out.m3u8'
result_transcode = os.system(cmd)

if result_transcode == 0:
  # set status ready
  f= open(status_file_path,"w+")
  f.write("ready")
  f.close()
  print("File transcoded - " + str(datetime.datetime.now()))
else:
  # set status bad_file
  f= open(status_file_path,"w+")
  f.write("bad_file")
  f.close()
  print(f'Script has error if TRANSCODE, code - {result_transcode}')

# END SCRIPT COMMANDS
