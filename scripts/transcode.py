import sys, os, time

# create base dir
origin_path = "/home/origin"
transcode_path = "/home/transcode"
if not os.path.isdir(origin_path): os.mkdir(origin_path)
if not os.path.isdir(transcode_path): os.mkdir(transcode_path)

#create master dir
origin_master_path = f'{origin_path}/{sys.argv[1]}'
transcode_master_path = f'{transcode_path}/{sys.argv[1]}'
if not os.path.isdir(origin_master_path): os.mkdir(origin_master_path)
if not os.path.isdir(transcode_master_path): os.mkdir(transcode_master_path)

# create uuid dir
origin_uuid_path = f'{origin_path}/{sys.argv[1]}/{sys.argv[2]}'
transcode_uuid_path = f'{transcode_path}/{sys.argv[1]}/{sys.argv[2]}'
if not os.path.isdir(origin_uuid_path): os.mkdir(origin_uuid_path)
if not os.path.isdir(transcode_uuid_path): os.mkdir(transcode_uuid_path)

# create status file and set status busy
status_file_path = f'{origin_path}/{sys.argv[1]}/{sys.argv[2]}/status.txt'
f= open(status_file_path,"w+")
f.write("busy")
f.close()

# start command transcode
cmd = f'docker run -v {transcode_uuid_path}:/tmp/workdir jrottenberg/ffmpeg -i {sys.argv[3]} -b:v:0 4000k -b:a:0 64k -map 0:v -map 0:a -f hls -var_stream_map "v:0,a:0"  -hls_list_size 0 -master_pl_name master.m3u8 -hls_segment_filename "vs%v/file_%03d.ts" vs%v/out.m3u8'
os.system(cmd)

# set status ready
f= open(status_file_path,"w+")
f.write("ready")
f.close()
