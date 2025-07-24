edit: forgot to add, the serverstats.sh has a config variable at the top to turn off/on automatic linux apt/yum/dnf updates and increase FX Logs. You will need a crontab/service that runs the monitor regularly, for you to take full advantage of autoupdates.

![alt text](https://i.ibb.co/DDQh7Wt8/serverstatustool1.png)
![alt text](https://i.ibb.co/9kKzMFdt/serverstatustool2.png)
![alt text](https://i.ibb.co/r2d7V0zb/serverstatustool4.png)



To use, create a new file using the command "vi healthcheck.sh" or "nano healthchech.sh" depending on your distro

for vi paste it, hit esc and type :wq and hit enter
for nano paste and hit shift O, then enter. After, hit ctrl X

next use the command "sudo chmod +x healthcheck.sh"
finally, to run type ./healthcheck.sh (this can be different depending on distro)

either this ^^ or upload the .sh with FTP and chmod it. That works also


For setting up a crontab ask chatgpt, I'm to lazy to write a guide currently.

ENJOY! Let me know if it comes in handy for you, took me an extra hour or two to put it together for the community :)
