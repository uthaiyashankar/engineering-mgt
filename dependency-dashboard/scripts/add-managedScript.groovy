import com.cloudbees.hudson.plugins.folder.*
import hudson.maven.*

/*Loop through all items inside a folder*/  
void processFolder(Item folder) {
  folder.getItems().each{
    if (it instanceof Folder) {
        processFolder(it)
    } else {
        addManageScript(it)
    }
  }
}

/*Configure maven deployer for a job*/
void addManageScript(Item job){
  Boolean exists = false;
  String scriptId="b8400b2f-959c-40e9-98ad-fb0a7ba60510";
  try {

    postBuilders = job.getPostbuilders()
    
    if (postBuilders != null){
    
      postBuilders.each{
            if (it instanceof org.jenkinsci.plugins.managedscripts.ScriptBuildStep) {

              if(it.getBuildStepId()==scriptId){
                println("This script already exits in : $job.name")
                exists=true;
              }
            }

      }
      
      if(exists == false){
        org.jenkinsci.plugins.managedscripts.ScriptBuildStep step = new org.jenkinsci.plugins.managedscripts.ScriptBuildStep(scriptId);
    	postBuildersConf=job.getPostbuilders().add(step);
    	job.save();
        println("This script added successfully for : $job.name");
      }
    }
  } catch (Exception e) {
    println("Error when adding script : $job.name")
    println(e)
  }
}

/*Loop through all Wilkes jenkins jobs*/
hudson.model.Hudson.instance.getView('random').items.each() { 
  def job = Jenkins.instance.getItem(it.fullDisplayName)
  if (job instanceof Folder) {
      processFolder(job)
  } else {
      addManageScript(job)
  }
}