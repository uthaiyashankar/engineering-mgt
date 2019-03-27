import com.cloudbees.hudson.plugins.folder.*
import hudson.maven.*

/*Loop through all items inside a folder*/

void processFolder(Item folder) {
    folder.getItems().each {
        if (it instanceof Folder) {
            processFolder(it)
        } else {
            addPostBuildActions(it)
        }
    }
}

/*Add the Html publisher plugin and artifact to archive script to the job post build action. */
void addPostBuildActions(Item job) {
    Boolean pluginExists = false;
    Boolean artifactExists = false;

    try {
        publishers = job.getPublishers()
        if (publishers != null) {
            publishers.each {
                if (it instanceof htmlpublisher.HtmlPublisher) {
                    htmlpublisher.HtmlPublisherTarget target = new htmlpublisher.HtmlPublisherTarget("Dependency Report", "target/site", "dependency-updates-report.html", true, false, true);
                    Boolean reportExists = false;
                    pluginExists = true;
                    list = it.getReportTargets();

                    for (report in list) {
                        if (report.getReportFiles() == "dependency-updates-report.html") {
                            reportExist = true;
                            println("Report already exists for $job.fullDisplayName");
                        }
                    }

                    if (reportExist == false) {
                        list.add(target);
                        htmlpublisher.HtmlPublisher html = new htmlpublisher.HtmlPublisher(list)
                        publisherConf = job.getPublishers().replace(html);
                        job.save();
                        println("Report does not exist, added for $job.fullDisplayName")
                    }
                }
                if (it instanceof hudson.tasks.ArtifactArchiver) {
                    artifactExists = true;
                    if (it.getArtifacts().contains("dependency-updates-report.xml") == false) {
                        hudson.tasks.ArtifactArchiver artifact = new hudson.tasks.ArtifactArchiver(it.getArtifacts() + ",target/dependency-updates-report.xml")
                        publisherConf = job.getPublishers().replace(artifact);
                        job.save();
                        println("Archive artifact added $job.fullDisplayName")
                    }
                }
            }
            if (artifactExists == false) {
                hudson.tasks.ArtifactArchiver artifact = new hudson.tasks.ArtifactArchiver("target/dependency-updates-report.xml")
                publisherConf = job.getPublishers().add(artifact);
                job.save();
                println("ArtifactArchiver does not exist, added for $job.fullDisplayName")
            }
            
            if (pluginExists == false) {
                List<htmlpublisher.HtmlPublisherTarget> list = new ArrayList<htmlpublisher.HtmlPublisherTarget>();
                htmlpublisher.HtmlPublisherTarget target = new htmlpublisher.HtmlPublisherTarget("Dependency Report", "target/site", "dependency-updates-report.html", true, false, true);
                list.add(target)
                htmlpublisher.HtmlPublisher html = new htmlpublisher.HtmlPublisher(list)
                publisherConf = job.getPublishers().add(html);
                job.save();
                println("Html publisher plugin with dependency report added for $job.fullDisplayName")
            }
        }
    } catch (Exception e) {
        println("Error when adding script : $job.fullDisplayName")
        println(e)
    }
}

/*Loop through all Wilkes jenkins jobs*/
hudson.model.Hudson.instance.getView('<Your view name>').items.each() {
    def job = Jenkins.instance.getItem(it.fullDisplayName)
    if (job instanceof Folder) {
        processFolder(job)
    } else {
        addPostBuildActions(job)
    }
}