#include <Python.h>
#include <ControlCmdMem.h>
#include <XmlVariables.h>

static ControlCmdMemory *cmem;
static PyObject         *DaqError;

static PyObject *intSendXml (const char *xml) {
   int count = 0;

   // Send string
   controlCmdSend(cmem,xml);

   // Wait for ack with timeout 
   while (controlCmdPending(cmem)) {
      usleep(1);

      // Timeout
      if ( count++ > 10000000 ) {
         printf("Timeout sending xml string\n");
         PyErr_SetString(DaqError,"Timeout sending xml string");
         return(NULL);
      }
   }
   usleep(100);

   // Check error buffer
   if ( strlen(controlErrorBuffer(cmem)) != 0 ) {
      printf("Error: %s\n",controlErrorBuffer(cmem));
      PyErr_SetString(DaqError,controlErrorBuffer(cmem));
      return(NULL);
   }
   usleep(100);

   // Success
   return(Py_BuildValue("i",1));
}

static PyObject *daqHardReset (PyObject *self, PyObject *args) {
   return (intSendXml("<system><command><HardReset/></command></system>\n"));
}

static PyObject *daqSoftReset (PyObject *self, PyObject *args) {
   return (intSendXml("<system><command><HardReset/></command></system>\n"));
}

static PyObject *daqRefreshstate(PyObject *self, PyObject *args) {
   return (intSendXml("<system><command><RefreshState/></command></system>\n"));
}

static PyObject *daqSetDefaults (PyObject *self, PyObject *args) {
   return (intSendXml("<system><command><SetDefaults/></command></system>\n"));
}

static PyObject *daqLoadSettings (PyObject *self, PyObject *args) {
   char       buffer[1024];
   const char *arg;

   if (!PyArg_ParseTuple(args, "s", &arg)) return NULL;

   sprintf(buffer,"<system><command><ReadXmlFile>%s</ReadXmlFile></command></system>\n",arg);
   return (intSendXml(buffer));
}

static PyObject *daqSaveSettings (PyObject *self, PyObject *args) {
   char       buffer[1024];
   const char *arg;

   if (!PyArg_ParseTuple(args, "s", &arg)) return NULL;

   sprintf(buffer,"<system><command><WriteConfigXml>%s</WriteConfigXml></command></system>\n",arg);
   return (intSendXml(buffer));
}

static PyObject *daqOpenData (PyObject *self, PyObject *args) {
   char       buffer[1024];
   const char *arg;

   if (!PyArg_ParseTuple(args, "s", &arg)) return NULL;

   sprintf(buffer,"<system><command><OpenDataFile>%s</OpenDataFile></command></system>\n",arg);
   return (intSendXml(buffer));
}

static PyObject *daqCloseData (PyObject *self, PyObject *args) {
   return (intSendXml("<system><command><CloseDataFile/></command></system>\n"));
}

static PyObject *daqSetRunParameters (PyObject *self, PyObject *args) {
   char       buffer[1024];
   const char *rate;
   int        count;

   if (!PyArg_ParseTuple(args, "si", &rate,&count)) return NULL;

   sprintf(buffer,"<system><config><RunRate>%s</RunRate><RunCount>%i</RunCount></config></system>\n",rate,count);
   return (intSendXml(buffer));
}

static PyObject *daqSetRunState (PyObject *self, PyObject *args) {
   char       buffer[1024];
   const char *state;

   if (!PyArg_ParseTuple(args, "s", &state)) return NULL;

   sprintf(buffer,"<system><command><SetRunState>%s</SetRunState></command></system>\n",state);
   return (intSendXml(buffer));
}

static PyObject *daqRunState (PyObject *self, PyObject *args) {
   XmlVariables vars;

   // Parse xml variables
   vars.parse("status",controlXmlStatusBuffer(cmem));

   // Success
   return(Py_BuildValue("s",vars.get("RunState").c_str()));
}

static PyObject *daqResetCounters (PyObject *self, PyObject *args) {
   return (intSendXml("<system><command><ResetCount/></command></system>\n"));
}

static PyObject *daqSendCommand (PyObject *self, PyObject *args) {
   char       buffer[1024];
   const char *cmd;
   const char *arg;

   if (!PyArg_ParseTuple(args, "ss", &cmd,&arg)) return NULL;

   sprintf(buffer,"<system><command><%s>%s</%s></command></system>\n",cmd,arg,cmd);
   return (intSendXml(buffer));
}

static PyObject *daqReadStatus (PyObject *self, PyObject *args) {
   return (intSendXml("<system><command><ReadStatus/></command></system>\n"));
}

static PyObject *daqGetStatus (PyObject *self, PyObject *args) {
   XmlVariables vars;
   const char   *var;

   if (!PyArg_ParseTuple(args, "s", &var)) return NULL;

   // Parse xml variables
   vars.parse("status",controlXmlStatusBuffer(cmem));

   // Success
   return(Py_BuildValue("s",vars.get(var).c_str()));
}

static PyObject *daqReadConfig (PyObject *self, PyObject *args) {
   return (intSendXml("<system><command><ReadConfig/></command></system>\n"));
}

static PyObject *daqVerifyConfig (PyObject *self, PyObject *args) {
   return (intSendXml("<system><command><VerifyConfig/></command></system>\n"));
}

static PyObject *daqSetConfig (PyObject *self, PyObject *args) {
   XmlVariables vars;
   char         buffer[1024];
   const char   *var;
   const char   *arg;

   if (!PyArg_ParseTuple(args, "ss", &var,&arg)) return NULL;

   sprintf(buffer,"<system><config>%s</config></system>\n",vars.setXml(var,arg).c_str());
   return (intSendXml(buffer));
}

static PyObject *daqGetConfig (PyObject *self, PyObject *args) {
   XmlVariables vars;
   const char   *var;

   if (!PyArg_ParseTuple(args, "s", &var)) return NULL;

   // Parse xml variables
   vars.parse("config",controlXmlConfigBuffer(cmem));

   // Success
   return(Py_BuildValue("s",vars.get(var).c_str()));
}

static PyObject *daqSystemStatus (PyObject *self, PyObject *args) {
   return(Py_BuildValue("s",controlStatBuffer(cmem)));
}

static PyObject *daqUserStatus (PyObject *self, PyObject *args) {
   return(Py_BuildValue("s",controlUserBuffer(cmem)));
}

static PyObject *daqGetError (PyObject *self, PyObject *args) {
   return(Py_BuildValue("s",controlErrorBuffer(cmem)));
}

static PyObject *daqSendXml (PyObject *self, PyObject *args) {
   const char *xml;

   if (!PyArg_ParseTuple(args, "s", &xml)) return NULL;

   return (intSendXml(xml));
}

static PyMethodDef DaqMethods[] = {
   {"daqHardReset",        daqHardReset,        METH_VARARGS, ""},
   {"daqSoftReset",        daqSoftReset,        METH_VARARGS, ""},
   {"daqRefreshState",     daqRefreshstate,     METH_VARARGS, ""},
   {"daqSetDefaults",      daqSetDefaults,      METH_VARARGS, ""},
   {"daqLoadSettings",     daqLoadSettings,     METH_VARARGS, ""},
   {"daqSaveSettings",     daqSaveSettings,     METH_VARARGS, ""},
   {"daqOpenData",         daqOpenData,         METH_VARARGS, ""},
   {"daqCloseData",        daqCloseData,        METH_VARARGS, ""},
   {"daqSetRunParameters", daqSetRunParameters, METH_VARARGS, ""},
   {"daqSetRunState",      daqSetRunState,      METH_VARARGS, ""},
   {"daqGetRunState",      daqRunState,         METH_VARARGS, ""},
   {"daqResetCounters",    daqResetCounters,    METH_VARARGS, ""},
   {"daqSendCommand",      daqSendCommand,      METH_VARARGS, ""},
   {"daqReadStatus",       daqReadStatus,       METH_VARARGS, ""},
   {"daqGetStatus",        daqGetStatus,        METH_VARARGS, ""},
   {"daqReadConfig",       daqReadConfig,       METH_VARARGS, ""},
   {"daqVerifyConfig",     daqVerifyConfig,     METH_VARARGS, ""},
   {"daqSetConfig",        daqSetConfig,        METH_VARARGS, ""},
   {"daqGetConfig",        daqGetConfig,        METH_VARARGS, ""},
   {"daqGetSystemStatus",  daqSystemStatus,     METH_VARARGS, ""},
   {"daqGetUserStatus",    daqUserStatus,       METH_VARARGS, ""},
   {"daqGetError",         daqGetError,         METH_VARARGS, ""},
   {"daqSendXml",          daqSendXml,          METH_VARARGS, ""},
   {NULL,                  NULL,                0,            NULL} /* Sentinel */
};

PyMODINIT_FUNC initpythonDaq(void) {
   PyObject *m;
   m = Py_InitModule("pythonDaq", DaqMethods);

   DaqError = PyErr_NewException("Daq.error",NULL,NULL);
   Py_INCREF(DaqError);
   PyModule_AddObject(m,"error",DaqError);

   /* Init shared memory */
   int r = controlCmdOpenAndMap(&cmem);
}

