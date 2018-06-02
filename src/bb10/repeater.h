/*
 *  TAO Translator
 *  Copyright (C) 2013-2018  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
 *
 *  $Id: $Format:%h %ai %an$ $
 *
 *  This file is part of TAO Translator.
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef REPEATER_H
#define REPEATER_H

#include <QList>
#include <bb/cascades/DataModel>
#include <bb/cascades/CustomControl>

namespace bb {
    namespace cascades {
        class Container;
    }
}

class Repeater: public bb::cascades::CustomControl
{
    Q_OBJECT

    Q_PROPERTY(bb::cascades::DataModel *model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(QDeclarativeComponent *delegate READ delegate WRITE setDelegate NOTIFY delegateChanged)

    Q_CLASSINFO("DefaultProperty", "delegate")

public:
    Repeater(bb::cascades::Container *parent = 0);

    bb::cascades::DataModel *model() const;
    void setModel(bb::cascades::DataModel *model);

    QDeclarativeComponent *delegate() const;
    void setDelegate(QDeclarativeComponent *delegate);

signals:
    void modelChanged();
    void delegateChanged();

private slots:
    void onItemAddedRemovedOrUpdated(const QVariantList &indexPath);
    void onItemsChanged(bb::cascades::DataModelChangeType::Type eChangeType,
                        QSharedPointer<bb::cascades::DataModel::IndexMapper> indexMapper);

private:
    void clear();
    void createDelegates();

    bb::cascades::DataModel *m_model;
    QDeclarativeComponent *m_delegate;
    QList<bb::cascades::Control *> m_controls;
};

#endif // REPEATER_H
