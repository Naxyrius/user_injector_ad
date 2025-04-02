# user_injector_ad

Injector script to quickly fill AD with Test profils

Use this to grab de main branch and unzip it

```Powershell
Invoke-WebRequest -Uri "https://github.com/Naxyrius/user_injector_ad/archive/refs/heads/main.zip" -OutFile "C:\main.zip"
```
Or, if you want it in Downloads folder, but you'll have to unzip and move it to C:\

```Powershell
Invoke-WebRequest -Uri "https://github.com/Naxyrius/user_injector_ad/archive/refs/heads/main.zip" -OutFile "$env:USERPROFILE\Downloads\main.zip"
```
