# user_injector_ad



Injector script to quickly fill AD with Test profils
If you want to use Dry Run, use the script with Option, you'll avec a Y/N question to use Dry Run or not.
If you don't want additional intéraction then take the version without Dry Run


Use this to grab de main branch and unzip it move the folder "user_injector_ad" to the C:\

```Powershell
Invoke-WebRequest -Uri "https://github.com/Naxyrius/user_injector_ad/archive/refs/heads/main.zip" -OutFile "C:\main.zip"
```
Or, if you want it in Downloads folder, but you'll have to unzip and move it to C:\

```Powershell
Invoke-WebRequest -Uri "https://github.com/Naxyrius/user_injector_ad/archive/refs/heads/main.zip" -OutFile "$env:USERPROFILE\Downloads\main.zip"
```
```


             )    
             \   )   
             ()  \                           )
                 ()                       )  \
                       .-"""-.            \  ()
              ____    /  __   `\     __   ()
           .'`  __'. | o/__\o   |   / /|
          /  o /__\o;\  \\//   /_  // /
 ._      _|    \\// |`-.__.-'|\  `;  /
/  \   .'  \-.____.'|   ||   |/    \/
`._ '-/             |   ||   '.___./
.  '-.\_.-'      __.'-._||_.-' _ /
.`""===(||).___.(||)(||)----'(||)===...__
 `"doudoune"`""=====""""========"""====...__  `""==._
                                       `"=.     `"=.
                                           `"=.

```                                           