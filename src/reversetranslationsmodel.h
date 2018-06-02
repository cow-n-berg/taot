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

#ifndef REVERSETRANSLATIONSMODEL_H
#define REVERSETRANSLATIONSMODEL_H

#include <QAbstractListModel>
#include <QString>
#include <QStringList>

class ReverseTranslationsModel: public QAbstractListModel
{
    Q_OBJECT

public:
    enum ReverseTranslationRoles {
        TermRole = Qt::UserRole + 1,
        SynonymsRole,
        TranslationsRole
    };

    explicit ReverseTranslationsModel(QObject *parent = 0);

    QHash<int, QByteArray> roleNames() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    void append(const QString &term, const QStringList &synonyms, const QStringList &translations);

private:
    QList<QPair<QString, QPair<QStringList, QStringList> > > m_terms;
};

Q_DECLARE_METATYPE(ReverseTranslationsModel *)

#endif // REVERSETRANSLATIONSMODEL_H
