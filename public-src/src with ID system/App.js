import React, { useState, useEffect, useCallback } from 'react';
import Axios from 'axios';
import GetId from './GetId'
import './App.css';

function App() {
    const [display, setDisplay] = useState(false);
    const [queue, setQueue] = useState([]);
    const [id, setId] = useState(0);
    const [name, setName] = useState("Invalid");
    const [listIndex, setlistIndex] = useState(0);
    const listItems = [
        { label: 'Drag', action: () => Axios.post('http://jcrp-toolbox/executeCommand', JSON.stringify(`drag ${id}`)) },
        { label: 'Cuff / Uncuff', action: () => Axios.post('http://jcrp-toolbox/executeCommand', JSON.stringify(`cuff ${id}`)) },
        { label: 'Check pulse', action: () => Axios.post('http://jcrp-toolbox/action', JSON.stringify({action: 'GetPulse', id: id})) },
        { label: 'Ask for id', action: () => Axios.post('http://jcrp-toolbox/action', JSON.stringify({action: 'GetId', id: id})) },
        { label: 'Breathalize', action: () => Axios.post('http://jcrp-toolbox/action', JSON.stringify({action: 'Breathalize', id: id})) },
    ]

    if (queue.length > 0 && display) {
        setDisplay(false)
        Axios.post('http://jcrp-toolbox/close', JSON.stringify(''))
    }

    const handleMessage = useCallback(event => {
        const data = event.detail.data //IMPORTANT REMOVE DETAIL FOR BUILD!
        switch (data.type) {
            case 'display':
                data.toogle !== undefined ? setDisplay(data.toogle) : console.error("Invalid NUI display toogle");
                setId(data.id);
                setName(data.name);
            break;
            case 'navigation':
                if (data.value === 'Up') {
                    listIndex === 0 ? setlistIndex(listItems.length -1) : setlistIndex(listIndex -1)
                } else if (data.value === 'Down') {
                    listIndex === listItems.length -1 ? setlistIndex(0) : setlistIndex(listIndex +1)
                } else if (data.value === "Enter") {
                    listItems[listIndex].action()
                }
            break;
            case 'addQueueItem':
                setQueue( prevState => [...prevState, {source: data.source, name: data.name, action: data.action}] )
            break;
            default:
        }
    }, [listItems, listIndex, setlistIndex])

    useEffect(() => {
        window.addEventListener('message', handleMessage)
        return () => {
            window.removeEventListener('message', handleMessage)
        }
    }, [handleMessage])

    const item = queue[0]

    return (
        item ?
            item.action === 'GetPulse' ?
                <GetId name={item.name} id={item.source} />
            : item.action === 'GetId' ?
                <GetId name={item.name} id={item.source} />
            : item.action === 'Breatalize' &&
                <GetId name={item.name} id={item.source} />
        :
            display &&
            <div className='Container'>
                <div className='title'>{`[${id}] ${name}`}</div>
                <ul>
                    {listItems.map((item, index) => (
                    <li key={index} className={index === listIndex ? 'selected' : ''}>{item.label}</li>
                    ))}
                </ul>
            </div>
    );
}

export default App;
