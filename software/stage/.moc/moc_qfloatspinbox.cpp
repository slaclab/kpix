/****************************************************************************
** FloatSpinBox meta object code from reading C++ file 'qfloatspinbox.h'
**
** Created: Fri Aug 13 13:24:13 2010
**      by: The Qt MOC ($Id: qt/moc_yacc.cpp   3.3.8   edited Feb 2 14:59 $)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#undef QT_NO_COMPAT
#include "../qfloatspinbox.h"
#include <qmetaobject.h>
#include <qapplication.h>

#include <private/qucomextra_p.h>
#if !defined(Q_MOC_OUTPUT_REVISION) || (Q_MOC_OUTPUT_REVISION != 26)
#error "This file was generated using the moc from 3.3.8. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

const char *FloatSpinBox::className() const
{
    return "FloatSpinBox";
}

QMetaObject *FloatSpinBox::metaObj = 0;
static QMetaObjectCleanUp cleanUp_FloatSpinBox( "FloatSpinBox", &FloatSpinBox::staticMetaObject );

#ifndef QT_NO_TRANSLATION
QString FloatSpinBox::tr( const char *s, const char *c )
{
    if ( qApp )
	return qApp->translate( "FloatSpinBox", s, c, QApplication::DefaultCodec );
    else
	return QString::fromLatin1( s );
}
#ifndef QT_NO_TRANSLATION_UTF8
QString FloatSpinBox::trUtf8( const char *s, const char *c )
{
    if ( qApp )
	return qApp->translate( "FloatSpinBox", s, c, QApplication::UnicodeUTF8 );
    else
	return QString::fromUtf8( s );
}
#endif // QT_NO_TRANSLATION_UTF8

#endif // QT_NO_TRANSLATION

QMetaObject* FloatSpinBox::staticMetaObject()
{
    if ( metaObj )
	return metaObj;
    QMetaObject* parentObject = QSpinBox::staticMetaObject();
    static const QUParameter param_slot_0[] = {
	{ "value", &static_QUType_ptr, "float", QUParameter::In }
    };
    static const QUMethod slot_0 = {"setValue", 1, param_slot_0 };
    static const QMetaData slot_tbl[] = {
	{ "setValue(float)", &slot_0, QMetaData::Public }
    };
    static const QUParameter param_signal_0[] = {
	{ "value", &static_QUType_ptr, "float", QUParameter::In }
    };
    static const QUMethod signal_0 = {"valueChanged", 1, param_signal_0 };
    static const QMetaData signal_tbl[] = {
	{ "valueChanged(float)", &signal_0, QMetaData::Public }
    };
    metaObj = QMetaObject::new_metaobject(
	"FloatSpinBox", parentObject,
	slot_tbl, 1,
	signal_tbl, 1,
#ifndef QT_NO_PROPERTIES
	0, 0,
	0, 0,
#endif // QT_NO_PROPERTIES
	0, 0 );
    cleanUp_FloatSpinBox.setMetaObject( metaObj );
    return metaObj;
}

void* FloatSpinBox::qt_cast( const char* clname )
{
    if ( !qstrcmp( clname, "FloatSpinBox" ) )
	return this;
    return QSpinBox::qt_cast( clname );
}

#include <qobjectdefs.h>
#include <qsignalslotimp.h>

// SIGNAL valueChanged
void FloatSpinBox::valueChanged( float t0 )
{
    if ( signalsBlocked() )
	return;
    QConnectionList *clist = receivers( staticMetaObject()->signalOffset() + 0 );
    if ( !clist )
	return;
    QUObject o[2];
    static_QUType_ptr.set(o+1,&t0);
    activate_signal( clist, o );
}

bool FloatSpinBox::qt_invoke( int _id, QUObject* _o )
{
    switch ( _id - staticMetaObject()->slotOffset() ) {
    case 0: setValue((float)(*((float*)static_QUType_ptr.get(_o+1)))); break;
    default:
	return QSpinBox::qt_invoke( _id, _o );
    }
    return TRUE;
}

bool FloatSpinBox::qt_emit( int _id, QUObject* _o )
{
    switch ( _id - staticMetaObject()->signalOffset() ) {
    case 0: valueChanged((float)(*((float*)static_QUType_ptr.get(_o+1)))); break;
    default:
	return QSpinBox::qt_emit(_id,_o);
    }
    return TRUE;
}
#ifndef QT_NO_PROPERTIES

bool FloatSpinBox::qt_property( int id, int f, QVariant* v)
{
    return QSpinBox::qt_property( id, f, v);
}

bool FloatSpinBox::qt_static_property( QObject* , int , int , QVariant* ){ return FALSE; }
#endif // QT_NO_PROPERTIES
