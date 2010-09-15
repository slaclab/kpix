/****************************************************************************
** customWidget meta object code from reading C++ file 'gui.h'
**
** Created: Tue Aug 17 16:06:42 2010
**      by: The Qt MOC ($Id: qt/moc_yacc.cpp   3.3.8   edited Feb 2 14:59 $)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#undef QT_NO_COMPAT
#include "../gui.h"
#include <qmetaobject.h>
#include <qapplication.h>

#include <private/qucomextra_p.h>
#if !defined(Q_MOC_OUTPUT_REVISION) || (Q_MOC_OUTPUT_REVISION != 26)
#error "This file was generated using the moc from 3.3.8. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

const char *customWidget::className() const
{
    return "customWidget";
}

QMetaObject *customWidget::metaObj = 0;
static QMetaObjectCleanUp cleanUp_customWidget( "customWidget", &customWidget::staticMetaObject );

#ifndef QT_NO_TRANSLATION
QString customWidget::tr( const char *s, const char *c )
{
    if ( qApp )
	return qApp->translate( "customWidget", s, c, QApplication::DefaultCodec );
    else
	return QString::fromLatin1( s );
}
#ifndef QT_NO_TRANSLATION_UTF8
QString customWidget::trUtf8( const char *s, const char *c )
{
    if ( qApp )
	return qApp->translate( "customWidget", s, c, QApplication::UnicodeUTF8 );
    else
	return QString::fromUtf8( s );
}
#endif // QT_NO_TRANSLATION_UTF8

#endif // QT_NO_TRANSLATION

QMetaObject* customWidget::staticMetaObject()
{
    if ( metaObj )
	return metaObj;
    QMetaObject* parentObject = QVBox::staticMetaObject();
    static const QUMethod slot_0 = {"updateDesiredXrel", 0, 0 };
    static const QUMethod slot_1 = {"updateDesiredYrel", 0, 0 };
    static const QUMethod slot_2 = {"updateDesiredZrel", 0, 0 };
    static const QUMethod slot_3 = {"updateDesiredXabs", 0, 0 };
    static const QUMethod slot_4 = {"updateDesiredYabs", 0, 0 };
    static const QUMethod slot_5 = {"updateDesiredZabs", 0, 0 };
    static const QUParameter param_slot_6[] = {
	{ 0, &static_QUType_int, 0, QUParameter::Out }
    };
    static const QUMethod slot_6 = {"moveXrel", 1, param_slot_6 };
    static const QUParameter param_slot_7[] = {
	{ 0, &static_QUType_int, 0, QUParameter::Out }
    };
    static const QUMethod slot_7 = {"moveYrel", 1, param_slot_7 };
    static const QUParameter param_slot_8[] = {
	{ 0, &static_QUType_int, 0, QUParameter::Out }
    };
    static const QUMethod slot_8 = {"moveZrel", 1, param_slot_8 };
    static const QUParameter param_slot_9[] = {
	{ 0, &static_QUType_int, 0, QUParameter::Out }
    };
    static const QUMethod slot_9 = {"moveXabs", 1, param_slot_9 };
    static const QUParameter param_slot_10[] = {
	{ 0, &static_QUType_int, 0, QUParameter::Out }
    };
    static const QUMethod slot_10 = {"moveYabs", 1, param_slot_10 };
    static const QUParameter param_slot_11[] = {
	{ 0, &static_QUType_int, 0, QUParameter::Out }
    };
    static const QUMethod slot_11 = {"moveZabs", 1, param_slot_11 };
    static const QUParameter param_slot_12[] = {
	{ 0, &static_QUType_int, 0, QUParameter::Out }
    };
    static const QUMethod slot_12 = {"sequence", 1, param_slot_12 };
    static const QUParameter param_slot_13[] = {
	{ 0, &static_QUType_int, 0, QUParameter::Out }
    };
    static const QUMethod slot_13 = {"locateHome", 1, param_slot_13 };
    static const QUParameter param_slot_14[] = {
	{ 0, &static_QUType_int, 0, QUParameter::Out }
    };
    static const QUMethod slot_14 = {"goHome", 1, param_slot_14 };
    static const QUParameter param_slot_15[] = {
	{ 0, &static_QUType_int, 0, QUParameter::Out }
    };
    static const QUMethod slot_15 = {"getPositionsFromMotors", 1, param_slot_15 };
    static const QUParameter param_slot_16[] = {
	{ 0, &static_QUType_int, 0, QUParameter::Out }
    };
    static const QUMethod slot_16 = {"resetHome", 1, param_slot_16 };
    static const QUParameter param_slot_17[] = {
	{ 0, &static_QUType_int, 0, QUParameter::Out }
    };
    static const QUMethod slot_17 = {"updateLaserWidth", 1, param_slot_17 };
    static const QUParameter param_slot_18[] = {
	{ 0, &static_QUType_int, 0, QUParameter::Out }
    };
    static const QUMethod slot_18 = {"updateLaserAmp", 1, param_slot_18 };
    static const QUParameter param_slot_19[] = {
	{ 0, &static_QUType_int, 0, QUParameter::Out }
    };
    static const QUMethod slot_19 = {"sendLaserParamsToLaser", 1, param_slot_19 };
    static const QUParameter param_slot_20[] = {
	{ 0, &static_QUType_int, 0, QUParameter::Out }
    };
    static const QUMethod slot_20 = {"pulseLaser", 1, param_slot_20 };
    static const QMetaData slot_tbl[] = {
	{ "updateDesiredXrel()", &slot_0, QMetaData::Public },
	{ "updateDesiredYrel()", &slot_1, QMetaData::Public },
	{ "updateDesiredZrel()", &slot_2, QMetaData::Public },
	{ "updateDesiredXabs()", &slot_3, QMetaData::Public },
	{ "updateDesiredYabs()", &slot_4, QMetaData::Public },
	{ "updateDesiredZabs()", &slot_5, QMetaData::Public },
	{ "moveXrel()", &slot_6, QMetaData::Public },
	{ "moveYrel()", &slot_7, QMetaData::Public },
	{ "moveZrel()", &slot_8, QMetaData::Public },
	{ "moveXabs()", &slot_9, QMetaData::Public },
	{ "moveYabs()", &slot_10, QMetaData::Public },
	{ "moveZabs()", &slot_11, QMetaData::Public },
	{ "sequence()", &slot_12, QMetaData::Public },
	{ "locateHome()", &slot_13, QMetaData::Public },
	{ "goHome()", &slot_14, QMetaData::Public },
	{ "getPositionsFromMotors()", &slot_15, QMetaData::Public },
	{ "resetHome()", &slot_16, QMetaData::Public },
	{ "updateLaserWidth()", &slot_17, QMetaData::Public },
	{ "updateLaserAmp()", &slot_18, QMetaData::Public },
	{ "sendLaserParamsToLaser()", &slot_19, QMetaData::Public },
	{ "pulseLaser()", &slot_20, QMetaData::Public }
    };
    metaObj = QMetaObject::new_metaobject(
	"customWidget", parentObject,
	slot_tbl, 21,
	0, 0,
#ifndef QT_NO_PROPERTIES
	0, 0,
	0, 0,
#endif // QT_NO_PROPERTIES
	0, 0 );
    cleanUp_customWidget.setMetaObject( metaObj );
    return metaObj;
}

void* customWidget::qt_cast( const char* clname )
{
    if ( !qstrcmp( clname, "customWidget" ) )
	return this;
    return QVBox::qt_cast( clname );
}

bool customWidget::qt_invoke( int _id, QUObject* _o )
{
    switch ( _id - staticMetaObject()->slotOffset() ) {
    case 0: updateDesiredXrel(); break;
    case 1: updateDesiredYrel(); break;
    case 2: updateDesiredZrel(); break;
    case 3: updateDesiredXabs(); break;
    case 4: updateDesiredYabs(); break;
    case 5: updateDesiredZabs(); break;
    case 6: static_QUType_int.set(_o,moveXrel()); break;
    case 7: static_QUType_int.set(_o,moveYrel()); break;
    case 8: static_QUType_int.set(_o,moveZrel()); break;
    case 9: static_QUType_int.set(_o,moveXabs()); break;
    case 10: static_QUType_int.set(_o,moveYabs()); break;
    case 11: static_QUType_int.set(_o,moveZabs()); break;
    case 12: static_QUType_int.set(_o,sequence()); break;
    case 13: static_QUType_int.set(_o,locateHome()); break;
    case 14: static_QUType_int.set(_o,goHome()); break;
    case 15: static_QUType_int.set(_o,getPositionsFromMotors()); break;
    case 16: static_QUType_int.set(_o,resetHome()); break;
    case 17: static_QUType_int.set(_o,updateLaserWidth()); break;
    case 18: static_QUType_int.set(_o,updateLaserAmp()); break;
    case 19: static_QUType_int.set(_o,sendLaserParamsToLaser()); break;
    case 20: static_QUType_int.set(_o,pulseLaser()); break;
    default:
	return QVBox::qt_invoke( _id, _o );
    }
    return TRUE;
}

bool customWidget::qt_emit( int _id, QUObject* _o )
{
    return QVBox::qt_emit(_id,_o);
}
#ifndef QT_NO_PROPERTIES

bool customWidget::qt_property( int id, int f, QVariant* v)
{
    return QVBox::qt_property( id, f, v);
}

bool customWidget::qt_static_property( QObject* , int , int , QVariant* ){ return FALSE; }
#endif // QT_NO_PROPERTIES
