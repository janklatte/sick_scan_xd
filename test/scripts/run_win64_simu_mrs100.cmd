REM 
REM Run a basic sick_generic_caller unittest on Windows 64 (standalone, no ROS required) with a test server emulating a basic MRS100 device
REM 

rem set PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\Shared\Python36_64;%ProgramFiles(x86)%\Microsoft Visual Studio\Shared\Python37_64;%PATH%
rem set PATH=c:\vcpkg\installed\x64-windows\bin;%PATH%

REM 
REM Convert pcapng-files to msgpack and json
REM pip install msgpack
REM 
REM pushd ..\python
REM python --version
REM REM 
REM REM Convert 20220915_mrs100_msgpack_output.pcapng to msgpack/json (16-bit RSSI record)
REM REM 
REM del /f/q mrs100_dump*.msgpack
REM del /f/q mrs100_dump*.msgpack.hex
REM start python mrs100_receiver.py
REM python mrs100_pcap_player.py --pcap_filename=../emulator/scandata/20220915_mrs100_msgpack_output.pcapng --udp_port=2115 --verbose=1
REM move /y .\mrs100_dump_23644.msgpack     20220915_mrs100_msgpack_output.msgpack
REM move /y .\mrs100_dump_23644.msgpack.hex 20220915_mrs100_msgpack_output.msgpack.hex 
REM REM 
REM REM Convert 20210929_mrs100_token_udp.pcapng to msgpack/json (8-bit RSSI record)
REM REM 
REM del /f/q mrs100_dump*.msgpack
REM del /f/q mrs100_dump*.msgpack.hex
REM start python mrs100_receiver.py
REM python mrs100_pcap_player.py --pcap_filename=../emulator/scandata/20210929_mrs100_token_udp.pcapng --verbose=0
REM move /y .\mrs100_dump_12472.msgpack     20210929_mrs100_token_udp.msgpack
REM move /y .\mrs100_dump_12472.msgpack.hex 20210929_mrs100_token_udp.msgpack.hex 
REM del /f/q mrs100_dump*.msgpack
REM del /f/q mrs100_dump*.msgpack.hex
REM popd

REM 
REM Start sopas test server
REM 

pushd ..\..\build_win64
python --version
start "python mrs100_sopas_test_server.py" cmd /k python ../test/python/mrs100_sopas_test_server.py --tcp_port=2111 --cola_binary=0
@timeout /t 3

REM 
REM Start sick_generic_caller
REM 

start "sick_generic_caller" cmd /k .\Debug\sick_generic_caller.exe ../launch/sick_scansegment_xd.launch hostname:=127.0.0.1 udp_receiver_ip:=127.0.0.1
@timeout /t 3

REM 
REM Run pcapng player:
REM   20220915_mrs100_msgpack_output.pcapng: 16-bit RSSI
REM   20210929_mrs100_token_udp.pcapng and 20210929_mrs100_cola-a-start-stop-scandata-output.pcapng: 8-bit RSSI
REM 

@echo.
@echo Playing pcapng-files to emulate MRS100. Note: Start of UDP msgpacks in 20220915_mrs100_msgpack_output.pcapng takes a while...
@echo.
rem python ../test/python/mrs100_pcap_player.py --pcap_filename=../test/emulator/scandata/20220915_mrs100_msgpack_output.pcapng --udp_port=2115 --verbose=1
rem python ../test/python/mrs100_pcap_player.py --pcap_filename=../test/emulator/scandata/20220915_mrs100_msgpack_output.pcapng --udp_port=2115 --send_rate=240
python ../test/python/mrs100_pcap_player.py --pcap_filename=../test/emulator/scandata/20220915_mrs100_msgpack_output.pcapng --udp_port=2115
@timeout /t 3
python ../test/python/mrs100_pcap_player.py --pcap_filename=../test/emulator/scandata/20210929_mrs100_token_udp.pcapng --udp_port=2115
@timeout /t 3
python ../test/python/mrs100_pcap_player.py --pcap_filename=../test/emulator/scandata/20210929_mrs100_cola-a-start-stop-scandata-output.pcapng --udp_port=2115
@timeout /t 3

popd
@pause
