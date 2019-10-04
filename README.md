
<h2>Transforms trx file into html</h2>

<p>This is a customized fork of Trxer by NivNavick.</p>

<ul>
  <li>Target .NET Core 2.2.</li>
  <li>Simpler layout</li>
  <li>Handles output from SpecFlow showing gherkin and captured images</li>
  <li>Click images to show them zoomed in modal dialog</li>
  <li>Custom title shows Bamboo build directory</li>
</ul>

<p>If appropriate Bamboo environment variables are available then the report includes:</p>

<ul>
  <li>Bamboo branch name along with build number</li>
  <li>Branch name is hyperlinked to reults URL page</li>
</ul>

<h2>Usage</h2>

PS> <b>dotnet .\TrxReporter.dll --input &lt;path-to-trx&gt; [--output &lt;output-path&gt;] [--title &lt;title&gt;]</b>

<ul>
--input path can be absolute or relative


--output path can be a directory or file, absolute or relative. If no filename is specified then the .trx filename is used.

--title of the report, default is "Testing Report"
</ul>

<h3>Original Trxer</h3>
<p>TrxerConsole: https://github.com/NivNavick/trxer/tree/master/TrxerConsole</p>


