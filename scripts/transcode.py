import sys, os, datetime, time

# create base dir
transcode_path = "/home/transcode"
uuid = sys.argv[1]
ip = sys.argv[2]
url = sys.argv[3]
name = sys.argv[4]
master_name = sys.argv[5]

if not os.path.isdir(transcode_path): os.mkdir(transcode_path)

#create master dir
transcode_master_path = f'{transcode_path}/{master_name}'
if not os.path.isdir(transcode_master_path): os.mkdir(transcode_master_path)

# create uuid dir
transcode_uuid_path = f'{transcode_master_path}/{uuid}'
if not os.path.isdir(transcode_uuid_path): os.mkdir(transcode_uuid_path)

# create uuid origin dir
transcode_origin_path = f'{transcode_uuid_path}/origin'
if not os.path.isdir(transcode_origin_path): os.mkdir(transcode_origin_path)

# Download file
def download_file(ip, url, transcode_origin_path):
  cmd = f'scp -oStrictHostKeyChecking=no -i /home/scripts/origin.key -P2022 root@{ip}:{url} {transcode_origin_path}'
  result_download = os.system(cmd)
  if result_download == 0:
    print("File downloaded - " + str(datetime.datetime.now()))
  else:
    print(f'Script has error if download file - {url}, code - {result_download}')
    time.sleep(60)
    download_file(ip, url, transcode_origin_path)

# START SCRIPT COMMANDS

# create status file and set status busy
status_file_path = f'{transcode_uuid_path}/status.txt'
f= open(status_file_path,"w+")
f.write("busy")
f.close()

print("Start compress script - " + str(datetime.datetime.now()))
# start download file
download_file(ip, url, transcode_origin_path)

# start command transcode
cmd = f'docker run -v {transcode_uuid_path}:/tmp/workdir jrottenberg/ffmpeg -i /tmp/workdir/origin/{name} -b:v:0 4000k -b:a:0 64k -map 0:v -map 0:a -f hls -var_stream_map "v:0,a:0"  -hls_list_size 0 -master_pl_name master.m3u8 -hls_segment_filename "vs%v/file_%03d.ts" vs%v/out.m3u8'
os.system(cmd)

print("File transcoded - " + str(datetime.datetime.now()))

# set status ready
f= open(status_file_path,"w+")
f.write("ready")
f.close()

# END SCRIPT COMMANDS
