using System.Reflection;

namespace Mosaic.FrontEnd.Client.Data
{
    // from https://www.hanselman.com/blog/adding-a-git-commit-hash-and-azure-devops-build-number-and-build-id-to-an-aspnet-website
    public class AppVersionInfo
    {
        //private static readonly string _buildFileName = ".buildinfo.json";
        //private string _buildFilePath;
        //private string _buildNumber;
        //private string _buildId;
        private string? _gitHash;
        private string? _gitShortHash;

        //public AppVersionInfo(IHostEnvironment hostEnvironment)
        //{
        //    _buildFilePath = Path.Combine(hostEnvironment.ContentRootPath, _buildFileName);
        //}

        //public string BuildNumber
        //{
        //    get
        //    {
        //        // Build number format should be yyyyMMdd.# (e.g. 20200308.1)
        //        if (string.IsNullOrEmpty(_buildNumber))
        //        {
        //            if (File.Exists(_buildFilePath))
        //            {
        //                var fileContents = File.ReadLines(_buildFilePath).ToList();

        //                // First line is build number, second is build id
        //                if (fileContents.Count > 0)
        //                {
        //                    _buildNumber = fileContents[0];
        //                }
        //                if (fileContents.Count > 1)
        //                {
        //                    _buildId = fileContents[1];
        //                }
        //            }

        //            if (string.IsNullOrEmpty(_buildNumber))
        //            {
        //                _buildNumber = DateTime.UtcNow.ToString("yyyyMMdd") + ".0";
        //            }

        //            if (string.IsNullOrEmpty(_buildId))
        //            {
        //                _buildId = "123456";
        //            }
        //        }

        //        return _buildNumber;
        //    }
        //}

        //public string BuildId
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_buildId))
        //        {
        //            var _ = BuildNumber;
        //        }

        //        return _buildId;
        //    }
        //}

        public string GitHash
        {
            get
            {
                if (string.IsNullOrEmpty(_gitHash))
                {
                    var version = "1.0.0+LOCALBUILD"; // Dummy version for local dev
                    var appAssembly = typeof(AppVersionInfo).Assembly;
                    Type attributeType = typeof(AssemblyInformationalVersionAttribute);
                    var infoVerAttr = appAssembly!.GetCustomAttributes(attributeType).FirstOrDefault();

                    if (infoVerAttr is AssemblyInformationalVersionAttribute)
                    {
                        var t = (AssemblyInformationalVersionAttribute)infoVerAttr;
                        if (t.InformationalVersion.Length > 6)
                        {
                            // Hash is embedded in the version after a '+' symbol, e.g. 1.0.0+a34a913742f8845d3da5309b7b17242222d41a21
                            version = t.InformationalVersion;
                        }
                    }
                    _gitHash = version.Substring(version.IndexOf('+') + 1);
                }

                return _gitHash;
            }
        }

        public string ShortGitHash
        {
            get
            {
                if (string.IsNullOrEmpty(_gitShortHash))
                {
                    _gitShortHash = GitHash.Substring(GitHash.Length - 6, 6);
                }
                return _gitShortHash;
            }
        }
    }
}
