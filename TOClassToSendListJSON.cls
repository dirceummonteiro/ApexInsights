public with sharing class GestaoFilasLWCController {
    //Retorna os dados por UserName
    @AuraEnabled
    public static String getDataFromUser(){
        List<DataUserTO> listaTO = new List<DataUserTO>();
        Profile profile =  [Select name,id from profile where Name = 'Solver'];
        List<User> userList = [Select Name,(Select Id from ServiceResources) from User];

        List<ServiceResource> listResource = [Select Id,RelatedRecord.Name,EPS__c,RelatedRecord.EPS__c,(Select Skill.MasterLabel,SkillLevel,UserName__c,EPS__c,SkillDeveloperName__c from ServiceResourceSkills) from ServiceResource where ResourceType= 'A'];
        ActionTO actEdit = new ActionTO('Editar','editar');
        ActionTO actDelete = new ActionTO('Excluir','excluir');
        
        for(ServiceResource resource : listResource){            
            DataUserTO data = new DataUserTO();         
            data.userName = resource.RelatedRecord.Name;
            data.eps = resource.RelatedRecord.eps__c;
            data.action.add(actEdit);
            data.action.add(actDelete);
            for (ServiceResourceSkill resourceSkill : resource.ServiceResourceSkills) {

                ChildrenUserTO cTO = new ChildrenUserTO();
                cTO.skillName = resourceSkill.Skill.MasterLabel;
                cTO.skillLevel = resourceSkill.SkillLevel+'';
                cTO.action.add(actEdit);
                cTO.action.add(actDelete);
                data.children.add(cTO);                
            } 
            listaTO.add(data);


            
        }

        String listaJSON = JSON.serialize(listaTO);
        
        system.debug(listaJSON);
        return listaJSON;


    }







    //Retorna os dados por SkillName
    @AuraEnabled
    public static String getDataFromSkill(){
        List<DataSkillTO> listaTO = new List<DataSkillTO>();
        Profile profile =  [Select name,id from profile where Name = 'Solver'];
        List<User> userList = [Select Name,(Select Id from ServiceResources) from User];

        List<ServiceResource> listResource = [Select Id,Name,RelatedRecord.Name,EPS__c,(Select Skill.MasterLabel,SkillLevel,UserName__c,EPS__c,SkillDeveloperName__c from ServiceResourceSkills) from ServiceResource where ResourceType= 'A'];
        
        
        Map<String,DataSkillTO> mapDataSkill = new Map<String,DataSkillTO>();
        actionTO actEdit = new ActionTO('Editar','editar');
        actionTO actDelete = new ActionTO('Excluir','excluir');


        for(ServiceResource resource : listResource){            
            
    
            for (ServiceResourceSkill resourceSkill : resource.ServiceResourceSkills) {
                DataSkillTO data = mapDataSkill.get(resourceSkill.SkillDeveloperName__c);      

   

                if (data == null){
                    data = new DataSkillTO();
                    data.skillName = resourceSkill.Skill.MasterLabel;
                    data.action.add(actEdit);
                    data.action.add(actDelete);
                    mapDataSkill.put(data.skillName, data);
                } 

                ChildrenSkillTO cTO = new ChildrenSkillTO();
                cTO.userName = resource.RelatedRecord.Name;
                cTO.skillLevel = resourceSkill.SkillLevel+'';
                cTO.eps = resourceSkill.eps__c;
                cTO.action.add(actEdit);
                cTO.action.add(actDelete);
                data.children.add(cTO);                
            } 



            
        }
        

        String listaJSON = JSON.serialize(mapDataSkill.values());
        
        system.debug(listaJSON);
        return listaJSON;


    }





    public class DataUserTO {

        public String userName;
        public String eps;
        public List<ChildrenUserTO> children = new  List<ChildrenUserTO>();
        public List<ActionTO> action = new List<ActionTO>();

    }

    public class ChildrenUserTO {

        public String skillName;
        public String skillLevel;
        public List<ActionTO> action = new List<ActionTO>();




    }



    public class DataSkillTO {
        public String skillName;
        public List<ActionTO> action = new List<ActionTO>();


        public List<ChildrenSkillTO> children = new  List<ChildrenSkillTO>();
    }

    public class ChildrenSkillTO {
        public String userName;
        public String eps;
        public String skillLevel;
        public List<ActionTO> action = new List<ActionTO>();


    }

    public class ActionTO{
        public String label;
        public String name;

        public ActionTO (String label,String name){
            this.label = label;
            this.name = name;
        }
    }
}
