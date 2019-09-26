/// <summary>
/// Moved inline C# from XSL to this class because .NET Core can't compiled inline code.
/// This class is registered in the main program with AddExtensionObject
/// </summary>

namespace TrxReporter
{
	using System;
	using System.Text;
	using System.Text.RegularExpressions;

	public class Pens
	{

		/// <summary>
		/// Format output written by SpedFlow/Gherkin including images
		/// </summary>
		/// <param name="output"></param>
		/// <returns></returns>
		public string FormatOutput(string output)
		{
			var builder = new StringBuilder();
			foreach (var line in output.Split("\n"))
			{
				if (line.StartsWith("->"))
				{
					var text = line.Substring(2).Trim();
					var esc = "-> " + text.Replace("<", "&lt;").Replace(">", "&gt;");

					if (text.StartsWith("error"))
						builder.Append($"<span class=\"traceError\">{esc}</span><br/>\n");
					else
						builder.Append($"<span class=\"traceMessage\">{esc}</span><br/>\n");
				}
				else
				{
					var esc = line.Replace("<", "&lt;").Replace(">", "&gt;");
					builder.Append($"{esc}</br>\n");
				}
			}

			return builder.ToString()
				.Replace("HTMLREPORT_START_", "<br/><img onclick=\"OpenInPictureBox(this)\" src=")
				.Replace("HTMLREPORT_END_", "/><br/>");

		}


		/// <summary>
		/// Extract the build folder name from the storage location. This is a custom
		/// implementation for Bamboo build paths of the form C:\builds\build-name\....
		/// </summary>
		/// <param name="storage">
		/// A path of the form C:\builds\build-name\...
		/// </param>
		/// <returns>
		/// Just the "build-name" part of the path
		/// </returns>
		public string GetBuildName(string storage)
		{
			var parts = storage.Split(System.IO.Path.DirectorySeparatorChar);
			if (parts.Length > 1)
			{
				return parts[2].Trim();
			}

			return String.Empty;
		}


		/// <summary>
		/// Extract just the feature name from the given fully qualified class name.
		/// </summary>
		/// <param name="qualifiedName">
		/// A fully qualified .NET class name of the form
		/// namespace.folder...class, assembly, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
		/// </param>
		/// <returns>
		/// Just the "class" name from the fully qualified name
		/// </returns>
		public string GetFeatureName(string qualifiedName)
		{
			var comma = qualifiedName.IndexOf(',');
			if (comma > 0)
			{
				var name = qualifiedName.Substring(0, comma);
				var parts = name.Split('.');
				if (parts.Length > 0)
				{
					return parts[parts.Length - 1].Trim();
				}

				return name;
			}

			return qualifiedName;
		}

		public string GetShortDateTime(string time)
		{
			if (string.IsNullOrEmpty(time))
			{
				return string.Empty;
			}

			return DateTime.Parse(time).ToString();
		}


		public string GetYear()
		{
			return DateTime.Now.Year.ToString();
		}


		/// <summary>
		/// Custom name from test name and storage directory, extracting
		/// the Bamboo build part of the directory path.
		/// </summary>
		/// <param name="name"></param>
		/// <param name="storage"></param>
		/// <returns></returns>
		public string MakeCustomName (string name, string storage)
		{
			var build = GetBuildName(storage);
			if (build != String.Empty)
			{
				return build + " - " + name.Substring(name.IndexOf('@') + 1);
			}

			return name;
		}


		public string ToExactTimeDefinition(string duration)
		{
			if (string.IsNullOrEmpty(duration))
			{
				return string.Empty;
			}

			return ToExactTime(TimeSpan.Parse(duration).TotalMilliseconds);
		}


		public string ToExactTimeDefinition(string start, string finish)
		{
			var datetime = DateTime.Parse(finish) - DateTime.Parse(start);
			return ToExactTime(datetime.TotalMilliseconds);
		}


		private string ToExactTime(double ms)
		{
			if (ms < 1000)
				return ms + " ms";

			if (ms >= 1000 && ms < 60000)
				return string.Format("{0:0.00} seconds", TimeSpan.FromMilliseconds(ms).TotalSeconds);

			if (ms >= 60000 && ms < 3600000)
				return string.Format("{0:0.00} minutes", TimeSpan.FromMilliseconds(ms).TotalMinutes);

			return string.Format("{0:0.00} hours", TimeSpan.FromMilliseconds(ms).TotalHours);
		}
	}
}
