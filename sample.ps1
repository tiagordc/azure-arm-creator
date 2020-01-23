
$download = "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"
New-Item -ItemType Directory -Force -Path "C:\DOWNLOADED"
Invoke-WebRequest $download -OutFile "C:\DOWNLOADED\dummy.pdf"
