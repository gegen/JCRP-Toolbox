import React, { useState, useEffect, useCallback, Children } from 'react';
import Axios from 'axios';

export default function Menu({ title, children }) {
    const [display, setDisplay] = useState(false);
    const [subMenuOrder, setSubMenuOrder] = useState([]);
    const [listIndex, setListIndex] = useState(0);

    let menuTitle = title
    let menuStructure = children

    for (let i = 0; i < subMenuOrder.length; i++) {
        if (menuStructure.length) {
            if (i === subMenuOrder.length - 1) menuTitle = menuStructure[subMenuOrder[i]].props.title ?? menuStructure[subMenuOrder[i]].props.label
            menuStructure = menuStructure[subMenuOrder[i]].props.children
        } else {
            if (i === subMenuOrder.length - 1) menuTitle = menuStructure.props.title ?? menuStructure.props.label
            menuStructure = menuStructure.props.children
        }
    }

    const itemCount = Children.toArray(menuStructure).length;
    if (itemCount - 1 < listIndex) {
        setListIndex(itemCount - 1)
    }

    const handleMessage = useCallback(event => {
        if (!event.data) return
        const data = event.data
        switch (data.type) {
            case 'display':
                data.toogle !== undefined ? setDisplay(data.toogle) : console.error("Invalid NUI display toogle");
                break
            case 'navigation':
                if (data.value === 'Up') {
                    listIndex === 0 ? setListIndex(menuStructure.length - 1) : setListIndex(listIndex - 1)
                } else if (data.value === 'Down') {
                    listIndex === menuStructure.length - 1 ? setListIndex(0) : setListIndex(listIndex + 1)
                } else if (data.value === "Enter") {
                    const currentItem = Children.toArray(menuStructure)[listIndex]
                    if (currentItem.props.restricted) {
                        Axios.post('http://jcrp-toolbox/notification', JSON.stringify('~r~Only first responder have access.'))
                    } else {
                        if (currentItem.type === SubMenu) {
                            setListIndex(0)
                            setSubMenuOrder(prev => [...prev, listIndex])
                        }
                        if (currentItem.props.onSelect) currentItem.props.onSelect()
                    }
                } else if (data.value === "Back") {
                    if (subMenuOrder.length === 0) {
                        Axios.post('http://jcrp-toolbox/close', JSON.stringify())
                    } else {
                        setListIndex(subMenuOrder[subMenuOrder.length - 1])
                        setSubMenuOrder(subMenuOrder.filter((elm, index) => index < subMenuOrder.length - 1))
                    }
                }
                break
            default:
                break
        }
    }, [menuStructure, listIndex, subMenuOrder, setListIndex])

    useEffect(() => {
        window.addEventListener('message', handleMessage)
        return () => {
            window.removeEventListener('message', handleMessage)
        }
    }, [handleMessage])

    return (
        display &&
        <div className='Container'>
            <div className='title'>{menuTitle}</div>
            <ul>
                {Children.map(menuStructure, (child, index) => {
                    const selected = index === listIndex
                    const { label } = child.props
                    if (child.type === SubMenu) {
                        return <li className={selected ? 'selected' : ''}>{label} <span style={{ float: 'right', fontWeight: 'bold' }}>{'>'}</span></li>
                    }
                    return <li className={selected ? 'selected' : ''}>{label}</li>
                })}
            </ul>
        </div>
    )
}

export function Item() {
    return null
}

export function SubMenu() {
    return null
}