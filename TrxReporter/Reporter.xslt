<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl"
    xmlns:t="http://microsoft.com/schemas/VisualStudio/TeamTest/2010"
    xmlns:trxreport="urn:my-scripts"
    xmlns:pens="urn:Pens">
  <xsl:output method="html" indent="yes"/>
  <xsl:key name="TestMethods" match="t:TestMethod" use="@className"/>

  <xsl:template match="/" >
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
    <xsl:variable name="testRunName" select="/t:TestRun/@name" />
    <xsl:variable name="storage" select="/t:TestRun/t:TestDefinitions/t:UnitTest/@storage" />
    <xsl:variable name="reportTitle" select="pens:MakeCustomName($testRunName,$storage)" />
    <html>
      <head>
        <meta charset="utf-8"/>
        <link rel="stylesheet" type="text/css" href="Reporter.css"/>
        <script language="javascript" type="text/javascript" src="Reporter.js"></script>
        <title>
          <xsl:value-of select="$reportTitle"/>
        </title>
      </head>
      <body>
        <div id="wrapper" class="wrapper">

          <!-- Title - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
          
          <xsl:call-template name="BuildTitleBar">
            <xsl:with-param name="title" select="$reportTitle"/>
            <xsl:with-param name="countersExecuted" select="/t:TestRun/t:ResultSummary/t:Counters/@executed"/>
            <xsl:with-param name="countersPassed" select="/t:TestRun/t:ResultSummary/t:Counters/@passed"/>
            <xsl:with-param name="countersFailed" select="/t:TestRun/t:ResultSummary/t:Counters/@failed"/>
          </xsl:call-template>

          <div class="summaryWrapper">
            <div>
              <table class="info">
                <caption>Summary</caption>
                <thead>
                  <tr>
                    <th>Pie View</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>
                      <div id="summaryGraph"></div>
                    </td>
                  </tr>
                  <tr id="DownloadSection">
                    <td class="centered">
                      <a href="#" id="downloadButton" download="{/t:TestRun/@name}StatusesPie.png">Save graph</a>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div>
              <table class="info">
                <caption>Statuses</caption>
                <tbody>
                  <tr>
                    <th>Total</th>
                    <td class="centered">
                      <xsl:value-of select="/t:TestRun/t:ResultSummary/t:Counters/@total" />
                    </td>
                  </tr>
                  <tr>
                    <th>Executed</th>
                    <td class="centered">
                      <xsl:value-of select="/t:TestRun/t:ResultSummary/t:Counters/@executed" />
                    </td>
                  </tr>
                  <tr>
                    <th>Passed</th>
                    <td class="centered">
                      <xsl:value-of select="/t:TestRun/t:ResultSummary/t:Counters/@passed" />
                    </td>
                  </tr>
                  <tr>
                    <th>Failed</th>
                    <td class="centered">
                      <xsl:value-of select="/t:TestRun/t:ResultSummary/t:Counters/@failed" />
                    </td>
                  </tr>
                  <tr>
                    <th>Inconclusive</th>
                    <td class="centered">
                      <xsl:value-of select="/t:TestRun/t:ResultSummary/t:Counters/@inconclusive" />
                    </td>
                  </tr>
                  <tr>
                    <th>Error</th>
                    <td class="centered">
                      <xsl:value-of select="/t:TestRun/t:ResultSummary/t:Counters/@error" />
                    </td>
                  </tr>
                  <tr>
                    <th>Warning</th>
                    <td class="centered">
                      <xsl:value-of select="/t:TestRun/t:ResultSummary/t:Counters/@warning" />
                    </td>
                  </tr>
                  <tr>
                    <th>Timeout</th>
                    <td class="centered">
                      <xsl:value-of select="/t:TestRun/t:ResultSummary/t:Counters/@timeout" />
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div>
              <table class="info">
                <caption>Runtime/Context</caption>
                <tbody>
                  <xsl:for-each select="/t:TestRun/t:Times">
                    <tr>
                      <th>Start Time</th>
                      <td class="nowrap">
                        <xsl:value-of select="pens:GetShortDateTime(@start)" />
                      </td>
                    </tr>
                    <tr>
                      <th>End Time</th>
                      <td class="nowrap">
                        <xsl:value-of select="pens:GetShortDateTime(@finish)" />
                      </td>
                    </tr>
                    <tr>
                      <th>Duration</th>
                      <td class="nowrap">
                        <xsl:value-of select="pens:ToExactTimeDefinition(@start,@finish)"/>
                      </td>
                    </tr>
                  </xsl:for-each>
                  <tr>
                    <th>User</th>
                    <td class="nowrap">
                      <xsl:value-of select="/t:TestRun/@runUser" />
                    </td>
                  </tr>
                  <tr>
                    <th>Machine</th>
                    <td class="nowrap">
                      <xsl:value-of select="//t:UnitTestResult/@computerName" />
                    </td>
                  </tr>
                  <tr>
                    <th>Build</th>
                    <td class="nowrap">
                      <xsl:value-of select="pens:GetBuildName($storage)" />
                    </td>
                  </tr>
                  <tr>
                    <th>Description</th>
                    <td class="nowrap">
                      <xsl:value-of select="/t:TestRun/t:TestRunConfiguration/t:Description"/>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Details - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

          <xsl:variable name="features" select="//t:TestMethod[generate-id(.)=generate-id(key('TestMethods', @className))]" />
          <xsl:variable name="featureCount" select="count($features)" />

          <table id="ReportsTable" class="info section">
            <caption>
              All Scenarios By Feature (<xsl:value-of select="$featureCount" />)
            </caption>
            <thead>
              <tr>
                <th class="section">Status</th>
                <th class="section left">
                  <div style="float:left">Feature</div>
                  <div class="scenariosButton" onclick="ToggleAll('TestsContainer','scenariosButtonText','Expand','Collapse');">
                    <div class="scenariosButtonText" id="scenariosButtonText">Collapse</div>
                  </div>
                </th>
              </tr>
            </thead>
            <tbody>
              <xsl:for-each select="$features">
                <xsl:variable name="scenarios" select="key('TestMethods', @className)" />
                <xsl:variable name="scenarioCount" select="count($scenarios)" />

                <!-- Scenario header -->

                <tr>
                  <td class="PackageStatus">
                    <canvas id="{generate-id(@className)}canvas" width="100" height="25">
                    </canvas>
                  </td>
                  <td class="scenario" style="text-align:left">
                    <xsl:value-of select="pens:GetFeatureName(@className)" />
                  </td>
                </tr>
                <tr id="{generate-id(@className)}TestsContainer" class="visibleRow">
                  <td colspan="2">
                    <div class="dropArrow">&#8627;</div>
                    <table class="info">
                      <thead>
                        <tr>
                          <th class="TestsTable" style="width:80px;">
                            <div style="width:80px;min-width:80px;display:block;">Status</div>
                          </th>
                          <th class="TestsTable" style="text-align:left">
                            Scenario (<xsl:value-of select="$scenarioCount" />)
                          </th>
                          <th class="TestsTable" style="width:100px;">
                            <div style="width:100px;min-width:100px;">Duration</div>
                          </th>
                          <th style="width:80px">
                            <div style="width:80px;min-width:80px;">
                              <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
                            </div>
                          </th>
                        </tr>
                      </thead>
                      <tbody>
                        <xsl:for-each select="$scenarios">
                          <xsl:call-template name="BuildScenarioRow">
                            <xsl:with-param name="scenarioId" select="./../@id" />
                            <!--xsl:with-param name="testDescription" select="./../t:Description" /-->
                          </xsl:call-template>
                        </xsl:for-each>
                      </tbody>
                    </table>
                  </td>
                </tr>

                <script>
                  CalculateTestsStatuses(
                  '<xsl:value-of select="generate-id(@className)"/>TestsContainer',
                  '<xsl:value-of select="generate-id(@className)"/>canvas');
                </script>
              </xsl:for-each>
            </tbody>
          </table>

          <!-- Five Slowest - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

          <table class="info section">
            <caption>Five slowest scenarios</caption>
            <thead>
              <tr>
                <th class="section">Status</th>
                <th class="section left">Scenario</th>
                <th class="section">Duration</th>
              </tr>
            </thead>
            <tbody>
              <xsl:for-each select="/t:TestRun/t:Results/t:UnitTestResult">
                <xsl:sort select="@duration" order="descending"/>
                <xsl:if test="position() &gt;= 1 and position() &lt;=5">
                  <xsl:variable name="testId" select="@testId" />
                  <tr>
                    <xsl:call-template name="BuildStatusColumn">
                      <xsl:with-param name="outcome" select="/t:TestRun/t:Results/t:UnitTestResult[@testId=$testId]/@outcome" />
                    </xsl:call-template>
                    <td>
                      <xsl:value-of select="pens:GetFeatureName(/t:TestRun/t:TestDefinitions/t:UnitTest[@id=$testId]/t:TestMethod/@className)"/>.<xsl:value-of select="@testName"/>
                    </td>
                    <td class="nowrap">
                      <xsl:value-of select="pens:ToExactTimeDefinition(@duration)"/>
                    </td>
                  </tr>
                </xsl:if>
              </xsl:for-each>
            </tbody>
          </table>

          <footer>
            &#169; <xsl:value-of select="pens:GetYear()"/>, Internal Use Only
          </footer>
        </div>

        <div id="pictureBox" class="pictureBox" onclick="ClosePictureBox()">
          <img id="pictureBoxImg" />
        </div>

      </body>
      <script>
        CalculateTotalPrecents();
      </script>
    </html>
  </xsl:template>

  <!-- BuildTitleBar ========================================================================== -->

  <xsl:template name="BuildTitleBar">
    <xsl:param name="title" />
    <xsl:param name="countersExecuted" />
    <xsl:param name="countersPassed" />
    <xsl:param name="countersFailed" />
    <xsl:variable name="status">
      <xsl:choose>
        <xsl:when test="$countersFailed != 0">failed</xsl:when>
        <xsl:when test="($countersPassed + $countersFailed) &lt; $countersExecuted">completed</xsl:when>
        <xsl:otherwise>passed</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div class="titleBar {$status}">
      <div>
        <xsl:value-of select="$title"/>
      </div>
    </div>
  </xsl:template>

  <!-- BuildScenarioRow ======================================================================= -->

  <xsl:template name="BuildScenarioRow">
    <xsl:param name="scenarioId" />
    <xsl:for-each select="/t:TestRun/t:Results/t:UnitTestResult[@testId=$scenarioId]">
      <tr class="Test">
        <xsl:call-template name="BuildStatusColumn">
          <xsl:with-param name="outcome" select="@outcome" />
        </xsl:call-template>
        <td class="left">
          <xsl:value-of select="@testName" />
        </td>
        <td class="nowrap">
          <xsl:value-of select="pens:ToExactTimeDefinition(@duration)" />
        </td>
        <td>
          <div class="OpenMoreButton" onclick="ToggleOne('{$scenarioId}Details','{$scenarioId}DetailsButton','Show Gherkin','Hide Gherkin');">
            <div class="MoreButtonText" id="{$scenarioId}DetailsButton">Show Gherkin</div>
          </div>
        </td>
      </tr>
      <tr id="{$scenarioId}Details" class="Messages hiddenRow">
        <td>
          <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
        </td>
        <td class="Test Messages" colspan="3">
          <xsl:call-template name="BuildOutput">
            <xsl:with-param name="testId" select="$scenarioId" />
          </xsl:call-template>
        </td>
      </tr>
    </xsl:for-each>
  </xsl:template>

  <!-- BuildStatusColumn ====================================================================== -->

  <xsl:template name="BuildStatusColumn">
    <xsl:param name="outcome" />
    <xsl:choose>
      <xsl:when test="$outcome='Passed'">
        <td class="passed centered">
          PASSED
        </td>
      </xsl:when>
      <xsl:when test="$outcome='Failed'">
        <td class="failed centered">
          FAILED
        </td>
      </xsl:when>
      <xsl:when test="$outcome='Inconclusive'">
        <td class="warn centered">
          INCONCLUSIVE
        </td>
      </xsl:when>
      <xsl:when test="$outcome='Timeout'">
        <td class="failed centered">
          TIMEOUT
        </td>
      </xsl:when>
      <xsl:when test="$outcome='Error'">
        <td class="failed centered">
          ERROR
        </td>
      </xsl:when>
      <xsl:when test="$outcome='Warn'">
        <td class="warn centered">
          WARN
        </td>
      </xsl:when>
      <xsl:otherwise>
        <td class="info">
          OTHER
        </td>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- BuildOutput ============================================================================ -->

  <xsl:template name="BuildOutput">
    <xsl:param name="testId" />

    <xsl:for-each select="/t:TestRun/t:Results/t:UnitTestResult[@testId=$testId]/t:Output">
      <xsl:variable name="StdOut" select="t:StdOut"/>
      <xsl:if test="$StdOut">
        <xsl:value-of select="pens:FormatOutput($StdOut)" disable-output-escaping="yes" />
        <br/>
      </xsl:if>

      <xsl:variable name="stdErr" select="t:StdErr"/>
      <xsl:if test="$stdErr">
        <xsl:value-of select="$stdErr"/>
        <br/>
      </xsl:if>

      <xsl:variable name="error" select="t:ErrorInfo/t:Message"/>
      <xsl:if test="error">
        <div class="exMessage">
          <xsl:value-of select="$error"/>
          <br/>
        </div>
      </xsl:if>

      <xsl:if test="$stdErr or $error">
        <xsl:variable name="trace" select="/t:TestRun/t:Results/t:UnitTestResult[@testId=$testId]/t:Output/t:ErrorInfo/t:StackTrace" />
        <div class="stacktrace visibleRow" id="{generate-id($testId)}Stacktrace">
          <div class="dropArrow">&#8627;</div>
          <div class="exScroller">
            <pre class="exMessage">
              <!-- trim off the first space char -->
              <xsl:value-of select="substring($trace,2)" />
            </pre>
          </div>
        </div>
      </xsl:if>

    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>

