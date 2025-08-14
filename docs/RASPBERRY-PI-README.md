
# How to boot up ubuntu Server on Raspberry PI 5 (Headless)

## Requirements
1. Buy one Raspberry PI. In my case Raspberry PI 5 - 16GB RAM
2. Buy one memory card.
3. A memory card reader
4. A microHDMI cable if you want to see the logs OR you're going to boot up a OS with UI.
- In our case, we're going to boot up a server and then we will SSH into the server. So, no such requirement of microHDMI cable.

## Writing SD card.
1. On your PC, install raspberry PI imager. Here, Download for your machine

                    Image
2. Now, Click on Next \
   This pop-up will come.
Note: I have already configured my sd-card that's why I am seeing all the options.

                    Image

3. For first time you'll see something like this.

OR if you click on `No, Clear Settings` and then again click on next you'll see something like this.

4. Click on Edit Settings. NOTE: REMEMBER HOSTNAME, USERNAME AND PASSWORD, this will be useful when we'll ssh.

By Default you'll see this,

                    Image - with 5G config from video

                    Image

5. Here, you've to

- Enable Set hostname
- Enable set username and password
- Enable Configure wireless LAN. It will fill the details of the wifi network you're connected to. Also, keep in mind you connect with the 2GHz wifi network and avoid connecting with 5GHz one. It will save your days..\
- Select "IN" for Wireless LAN country. If you're in India. Here, I have selected 'US'. Because, I was not able to connect with 5GHz network of my router.
- and select the *locale settings * accordingly. I have kept it Asia/kolkata
- Keyboard Layout: "us"

                    Image - with 5G config from video

6. Now in SERVICES
Enable SSH and "Use password authentication" \
Like this,

                    Image

SAVE
YES

7. Let is erase your data. Consider taking a backup if your sd-card contains some important info

- Let it write, verify and finally flash your sd card.

- It will automatically eject your card from your laptop/system.

- Insert the sd card in Raspberry PI 5.

- Start the Raspberry PI 5. It will automatically connect with your Wifi, do the login and few other stuff.

- If you're not using HDMI cable and not seeing the logs.

- and if you're seeing the green light is blinking. It's a good signal

- You'll be able to ssh to it.

8. To verify you can, use command 'ping raspberry.local' you'll get output something like this,

```bash
$ ping raspberrypi.local

Pinging raspberrypi.local [fe80::8aa2:9eff:fe04:381c%15] with 32 bytes of data:
Reply from fe80::8aa2:9eff:fe04:381c%15: time=4ms 
Reply from fe80::8aa2:9eff:fe04:381c%15: time=4ms 
Reply from fe80::8aa2:9eff:fe04:381c%15: time=4ms 
Reply from fe80::8aa2:9eff:fe04:381c%15: time=4ms 

Ping statistics for fe80::8aa2:9eff:fe04:381c%15:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 4ms, Maximum = 4ms, Average = 4ms

```

OR you can login to your router portal and see the ip addr to login

                Image

9. Moment of Truth. SSH.
ssh <username>@<ip-addr>

$ ssh devarshrpi@192.168.1.94
devarshrpi@192.168.1.94's password: 
Welcome to Ubuntu 24.04.2 LTS (GNU/Linux 6.8.0-1018-raspi aarch64)
.
.
.
.
.
.
Last login: Sat Jul 19 14:14:19 2025 from 192.168.1.65