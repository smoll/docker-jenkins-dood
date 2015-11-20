import jenkins.*
import jenkins.model.*

master = Jenkins.instance
println("original label: " + master.getLabelString())
master.setLabelString(master.getLabelString() + " " + "docker")
println("new label: " + master.getLabelString())
