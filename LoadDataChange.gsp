/**
 *
 * How to use:
 * Step 1 : Place this package inside your src folder and do a codegen.
 * Step 2 : mention the folder path (on line 23) from which you need to pull the files
 * Step 3 : Right click on this code and click Run.
 * DONE... :)
 *
 * In case of certificate errors : download the cert from the site
 * and run the below code from java/lib/security folder
 * keytool -import -alias <alias> -keystore cacerts -file <cert_name.cer>
 */

//env to push the Scripts
var url = "https://app_url:port/app/ws/gw/wsi/pl/DataChangeAPI"
var username = "username"
var password = "password"

//Location the keep the output report (csv file)
var outputLocation : String = "C:/Users/pillai/Desktop/report/"

//Root folder to read the scripts
var root = "C:/Users/pillai/Desktop/input"
//Subfolders containing the file
var feed = {
    root.concat("/subfolder_1/"),
    root.concat("/subfolder_2/"),
    root.concat("/subfolder_3/")
}
run(feed)


/**
 * Main function
 * @param locations
 */
function run(locations : List<String>) {
  var cDate = Date.CurrentDate
  var nameSuffix = cDate.YYYYMMDDWithZero.remove("-").concat("_").concat(cDate.Hour as String).concat(cDate.Minute as String)
  var outputForFile = new StringBuilder()
  outputForFile.append("Slno,RefName, ResponsePublicID")
  foreach (location in locations) {
    var op = load(location, nameSuffix, false, false)
    outputForFile.append("\n").append(op)
  }
  print("\n-----------------------FINAL OUTPUT---------------------------------------------------\n")
  print(outputForFile?.toString())
  print("\n--------------------------------------------------------------------------------------\n")
  createFile(outputForFile.toString(), nameSuffix)
}

/**
 * Functin to load the data to prod
 * @param folder - Folder to read the file(s)
 * @param url - Service url
 * @param username - Service username
 * @param password - Service Password
 * @param nameAppender - Prefix
 * @param showFileNamesOnlyNow
 * @param supressErrors
 * @return
 */
function load(folder : String, nameSuffix : String = null, showFileNamesOnlyNow : boolean = true, supressErrors : boolean = false) : String {
  var folderContent = new java.io.File(folder)
  if (folderContent?.listFiles()?.Count <= 0) {
    print("Folder is empty...")
    return null
  }
  var finalOutput = new StringBuilder()
  var config = new gw.xml.ws.WsdlConfig()
  config.Guidewire.Authentication.Username = username
  config.Guidewire.Authentication.Password = password
  config.ServerOverrideUrl = url
  foreach (filePath in folderContent.listFiles()index i) {
    var fileName = filePath.Name.remove(".".concat(filePath.Extension))
    if (nameSuffix != "" and nameSuffix != null) {
      fileName = fileName.concat("_").concat(nameSuffix)
    }
    if (not showFileNamesOnlyNow) {
      print("Sending file : " + fileName)
      try {
        var gosu = new String(java.nio.file.Files.readAllBytes(java.nio.file.Paths.get(filePath.AbsolutePath)), java.nio.charset.StandardCharsets.UTF_8);
        var data = new tools.datachange.datachange.datachangeapi_1.DataChangeAPI(config)
        var response = data.updateDataChangeGosu(fileName, fileName, gosu)
        finalOutput.append("\n").append(i + 1).append(",").append(fileName).append(", ").append(response)
        print("Response: " + response)
      } catch (e : Exception) {
        print("Failed for record :" + fileName)
        e.printStackTrace()
        if (not  supressErrors) {
          break
        }
      }
    } else {
      print("File " + (i + 1) + " : " + fileName + " - " + fileName.length())
    }
  }
  if (not showFileNamesOnlyNow) {
    print("\n--------------------------------------------------------------------------------------\n")
    print(finalOutput?.toString())
    print("\n--------------------------------------------------------------------------------------\n")
  }
  return finalOutput.toString()
}

/**
 * Function to create the file
 */
function createFile(finalOutput : String, nameSuffix : String = null) {
  try {
    var opFile = outputLocation.concat("DatChangeOP")
    if (nameSuffix != "" and nameSuffix != null) {
      opFile = opFile.concat("_").concat(nameSuffix)
    }
    opFile = opFile.concat(".csv")
    new java.io.File(opFile).createNewFile()
    var writer = new java.io.PrintWriter(opFile, "UTF-8")
    writer.println(finalOutput)
    writer.close()
    print("CSV file available at : " + opFile)
  } catch (e) {
    print("Failed to save response to file : " + e.Message)
  }
}