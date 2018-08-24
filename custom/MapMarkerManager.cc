#include "MapMarkerManager.h"

#include <QDateTime>
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QtXml>

#include "MainWindow.h"
#include "VisualMissionItem.h"
#include "MissionController.h"
#include "PlanMasterController.h"

MapMarkerManager::MapMarkerManager(QObject *parent)
    :QObject(parent)
{
}

MapMarkerManager::~MapMarkerManager()
{
}

bool MapMarkerManager::loadXML(const QString &file)
{
    QFile f(file);
    if(!f.exists())
    {
        return false;
    }

    if (!f.open(QFile::ReadOnly | QFile::Text))
    {
        return false;
    }

    QDomDocument dom;
    if (!dom.setContent(&f))
    {
        return false;
    }

    QDomElement root = dom.documentElement();

    if(root.nodeName() != "markers")
    {
        return false;
    }

    _markers.clearAndDeleteContents();

    // Load from XML
    for(QDomElement m = root.firstChildElement("marker"); !m.isNull(); m = m.nextSiblingElement("marker"))
    {
        MapMarker *marker = new MapMarker(this);
        marker->setTimestamp(
                    QDateTime::fromString(
                        m.attribute("timestamp"),
                        "yyyy-MM-ddThh:mm:ss.zzz"
                        )
                    );
        marker->setCoordinate(
                    QGeoCoordinate(m.attribute("latitude").toDouble(),
                                   m.attribute("longitude").toDouble(),
                                   m.attribute("altitude").toDouble()
                                   )
                    );

        for(QDomElement i = m.firstChildElement("image"); !i.isNull(); i = i.nextSiblingElement("image"))
        {
            marker->addImage(i.text());
        }

        _markers.append(marker);
    }

    return true;
}

bool MapMarkerManager::saveXML(const QString &file)
{
    QFileInfo info(file);

    // Create path.
    if(!info.exists())
    {
        QDir().mkpath(info.absoluteDir().absolutePath());
    }

    QFile f(file);
    if (!f.open(QFile::WriteOnly | QFile::Truncate | QFile::Text)) {
        return false;
    }

    QDomDocument dom;

    // Add XML header
    QDomProcessingInstruction instruction;
    instruction = dom.createProcessingInstruction("xml","version=\"1.0\" encoding=\"utf-8\"");
    dom.appendChild(instruction);

    // Root
    QDomElement root = dom.createElement("markers");
    dom.appendChild(root);

    for(int i = 0; i < _markers.count(); i++) {
        MapMarker *marker = qobject_cast<MapMarker*>(_markers[i]);

        // Add marker
        QDomElement m = dom.createElement("marker");
        m.setAttribute("timestamp", marker->timestamp().toString("yyyy-MM-ddThh:mm:ss.zzz"));
        m.setAttribute("latitude", marker->coordinate().latitude());
        m.setAttribute("longitude", marker->coordinate().longitude());
        m.setAttribute("altitude", marker->coordinate().altitude());

        // Append images
        for(int j = 0; j < marker->images()->rowCount(); j++)
        {
            QString image = marker->images()->data(marker->images()->index(j)).toString();
            QDomElement e = dom.createElement("image");
            e.appendChild(dom.createTextNode(image));
            m.appendChild(e);
        }

        root.appendChild(m);
    }

    QTextStream s(&f);
    // 4 space intend
    dom.save(s, 4);

    return true;
}

bool MapMarkerManager::append(MapMarker* marker)
{
    if(!marker)
    {
        return false;
    }
    _markers.append(marker);
    return true;
}

bool MapMarkerManager::remove(MapMarker* marker)
{
    _markers.removeOne(marker);
    return true;
}

MapMarker* MapMarkerManager::add(void)
{
    MapMarker* marker = new MapMarker;
    _markers.append(marker);
    return marker;
}

MapMarker* MapMarkerManager::get(int index)
{
    return qobject_cast<MapMarker*>(_markers[index]);
}

bool MapMarkerManager::plan(void)
{
    MainWindow *mainWindow = MainWindow::instance();
    if(!mainWindow)
    {
        return false;
    }

    QList<PlanMasterController*> list = mainWindow->rootQmlObject()->findChildren<PlanMasterController*>("");
    if(list.count() == 0)
    {
        return false;
    }

    // QML engine will load up to 2 PlanMasterController, we only need the one in the plan view.
    PlanMasterController *masterController = nullptr;
    for(int i = 0; i < list.count(); i++)
    {
        PlanMasterController *controller = list.at(i);
        VisualMissionItem *item  = qobject_cast<VisualMissionItem*>(controller->missionController()->visualItems()->get(0));
        if(!item->flyView())
        {
            masterController = controller;
            break;
        }
    }

    if(masterController == nullptr)
    {
        return false;
    }

    masterController->removeAll();

    MissionController *missionController = masterController->missionController();

    QList<MapMarker*> markers;

    for(int i = 0; i < _markers.count(); i++)
    {
        markers.append(get(i));
    }

    VisualMissionItem *item  = qobject_cast<VisualMissionItem*>(missionController->visualItems()->get(0));
    // Takeoff behind home.
    int seq = missionController->insertSimpleMissionItem(item->coordinate(), 1);

    while(markers.count())
    {
        // Find the closest one.
        QGeoCoordinate pos = qobject_cast<VisualMissionItem*>(missionController->visualItems()->get(seq))->coordinate();
        qreal min_dist = DBL_MAX;
        int min_index = INT_MAX;

        for(int i = 0; i < markers.count(); i++)
        {
            MapMarker *marker = qobject_cast<MapMarker*>(markers.at(i));
            qreal dist = pos.distanceTo(marker->coordinate());
            if(dist < min_dist)
            {
                min_dist = dist;
                min_index = i;
            }
        }

        if(min_index == INT_MAX)
        {
            return false;
        }

        MapMarker *marker = qobject_cast<MapMarker*>(markers.at(min_index));
        seq = missionController->insertSimpleMissionItem(marker->coordinate(), seq + 1);
        markers.removeAt(min_index);
    }

    // Log all points.
    for(int i = 0; i < missionController->visualItems()->count(); i++)
    {
        VisualMissionItem *item  = qobject_cast<VisualMissionItem*>(missionController->visualItems()->get(i));
        qDebug() << item->commandDescription() << item->coordinate();
    }

    return true;
}
